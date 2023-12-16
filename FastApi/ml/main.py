import os
import cv2
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


def draw_boxes_sv(image_path, preds, model):
    image = cv2.imread(image_path)
    box_annotator = sv.BoxAnnotator(
        thickness=2,
        text_thickness=2,
        text_scale=1
    )
    detections = sv.Detections.from_ultralytics(preds)
    labels = [f"{model.names[class_id]} {confidence:0.2f}" for _, _, confidence, class_id, _ in detections]
    annotated_image = box_annotator.annotate(
        image,
        detections=detections,
        labels=labels
    )

    return annotated_image


if __name__ == "__main__":
    model = YOLO(...) # путь до детра

    path_to_photo = ''
    preds = model(path_to_photo, conf=0.41)[0]

    ans = draw_boxes(path_to_photo, preds, model)