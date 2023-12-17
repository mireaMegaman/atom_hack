from coco_detection import *
import supervision as sv
from transformers import (
    DetaForObjectDetection,
    DetaImageProcessor
)
import torch
import cv2


class Prediction:
    def __init__(self, model, cats):
        self.model = model
        self.categories = cats

    def fit_preidct(
            self,
            image_path: str,
            file_path: str
    ):

        CHECKPOINT = 'jozhang97/deta-resnet-50-24-epochs'
        CONFIDENCE_TRESHOLD = 0.5

        image_processor = DetaImageProcessor.from_pretrained(CHECKPOINT)

        id2label = {k: v['name'] for k,v in self.categories.items()}
        box_annotator = sv.BoxAnnotator()
        image = cv2.imread(image_path)

        # inference
        with torch.inference_mode():
            inputs = image_processor(images=image, return_tensors='pt').to(DEVICE)
            outputs = self.model(**inputs)
            target_sizes = torch.tensor([image.shape[:2]]).to(DEVICE)
            results = image_processor.post_process_object_detection(
                outputs=outputs,
                threshold=CONFIDENCE_TRESHOLD,
                target_sizes=target_sizes
            )[0]
            print(results)
            # annotate
            detections = sv.Detections.from_transformers(transformers_results=results).with_nms(threshold=0.5)
            class_ids = [class_id for _, _, class_id, _ in detections]
            labels = [f"{id2label[class_id]} {confidence:.2f}" for _, confidence, class_id, _ in detections]
            yolo_bboxes = []
            for bbox, _, _, _ in detections:
                x_min, y_min, x_max, y_max = bbox[0], bbox[1], bbox[2], bbox[3]
                x_center = (x_min + x_max) / 2
                y_center = (y_min + y_max) / 2
                width = x_max - x_min
                height = y_max - y_min
                yolo_bboxes.append([x_center / image.shape[1],
                                    y_center / image.shape[0],
                                    width / image.shape[1],
                                    height / image.shape[0]])
            yolo_file_format = [f'{label} {bbox[0]} {bbox[1]} {bbox[2]} {bbox[3]}\n' for label, bbox in zip(class_ids, yolo_bboxes)]
            cmd_code = 'w' if os.path.exists(file_path) else 'a'
            with open(file_path, cmd_code) as f:
                for i in yolo_file_format:
                    print(i, end='', file=f)
        return box_annotator.annotate(scene=image.copy(), detections=detections, labels=labels)


def collate_fn(batch):
    pixel_values = [item[0] for item in batch]
    encoding = image_processor.pad(pixel_values, return_tensors="pt")
    labels = [item[1] for item in batch]
    return {
        'pixel_values': encoding['pixel_values'],
        'pixel_mask': encoding['pixel_mask'],
        'labels': labels
    }


if __name__ == "__main__":

    DEVICE = torch.device('cuda:0' if torch.cuda.is_available() else 'cpu')
    CHECKPOINT = 'jozhang97/deta-resnet-50-24-epochs'
    CONFIDENCE_TRESHOLD = 0.5
    IOU_TRESHOLD = 0.8

    image_processor = DetaImageProcessor.from_pretrained(CHECKPOINT)

    MODEL_PATH = os.path.join('path/to/model/', 'custom-model')
    model = DetaForObjectDetection.from_pretrained(MODEL_PATH)
    model.to(DEVICE)

    categories = {0: {'id': 0, 'name': 'scuffing'},
                  1: {'id': 1, 'name': 'black spot'},
                  2: {'id': 2, 'name': 'crack'},
                  3: {'id': 3, 'name': 'marker'},
                  4: {'id': 4, 'name': 'mud'},
                  5: {'id': 5, 'name': 'nahcole'},
                  6: {'id': 6, 'name': 'n.d. nahcole'},
                  7: {'id': 7, 'name': 'microbump'},
                  8: {'id': 8, 'name': 'n.d. microbump'},
                  9: {'id': 9, 'name': 'dent'},
                  10: {'id': 10, 'name': 'mech.damage'},
                  11: {'id': 11, 'name': 'groove'},
                  12: {'id': 12, 'name': 'scratch'}}
    id2label = {k: v['name'] for k, v in categories.items()}

    pr = Prediction(model, categories)
    image_path = 'path/to/image'
    file_path = 'path/to/file_with_enshrined_annotations/'
    a = pr.fit_preidct(image_path, file_path)
