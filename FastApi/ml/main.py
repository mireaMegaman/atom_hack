import os
import torch
import random
import numpy as np

from ultralytics import RTDETR, YOLO
from cv2_converter import draw_boxes
import supervision as sv


def seed_everything(seed: int) -> None:
    """
    Set seed for reprodictibility
    :param seed: int, seed parameter
    :return: None
    """
    random.seed(seed)
    os.environ['PYTHONHASHSEED'] = str(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    torch.backends.cudnn.deterministic = True


def draw_boxes_sv(image, preds, CLASS_NAMES_DICT):
    box_annotator = sv.BoxAnnotator(
        color=sv.ColorPalette(),
        thickness=4,
        text_thickness=4,
        text_scale=2
    )
    detections = sv.Detections.from_ultralytics(preds)
    labels = [
        f"{CLASS_NAMES_DICT[class_id]} {confidence:0.2f}"
        for _, confidence, class_id, tracker_id
        in detections
    ]
    annotated_image = box_annotator.annotate(
        frame=image,
        detections=detections,
        labels=labels
    )

    return annotated_image



if __name__ == "__main__":
    model = RTDETR(...) # путь до детра
    CLASS_NAMES_DICT = model.model.names

    path_to_photo = ''
    preds = model(path_to_photo)


    ans = draw_boxes(preds)