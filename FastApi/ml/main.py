import os
import cv2
import torch
import random
import numpy as np

from ultralytics import RTDETR, YOLO
import supervision as sv
from tracker import tracking

from typing import Dict


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


def draw_boxes_sv(
        image_path,
        preds,
        class_name_dict
) -> np.ndarray:
    """
    Рисует красивые bbox
    :param image_path: путь до изображения
    :param preds: предсказания модели относительно картинки
    :param class_name_dict: словарь сопоставления индексов и названия классов
    :return: аннотированное изображение
    """
    image = cv2.imread(image_path)
    box_annotator = sv.BoxAnnotator(
        thickness=2,
        text_thickness=2,
        text_scale=1
    )
    detections = sv.Detections.from_ultralytics(preds)
    labels = [f"{class_name_dict[class_id]} {confidence:0.2f}" for _, _, confidence, class_id, _ in detections]
    annotated_image = box_annotator.annotate(
        image,
        detections=detections,
        labels=labels
    )

    return annotated_image


def count_classes(preds, class_name_dict):
    count_class = dict()

    class_id_detections = preds.boxes.cls.tolist()
    count_defects = len(class_id_detections)
    for id in class_id_detections:
        count_class[class_name_dict[int(id)]] = count_class.get(class_name_dict[int(id)], 0) + 1

    return count_class, count_defects


if __name__ == "__main__":
    model = YOLO(...) # путь до елки/детра
    class_name_dict = model.names

    path_to_photo = ''
    path_to_video = ''
    path_to_save_record = ''

    video_info = sv.VideoInfo.from_video_path(path_to_video)
    generator = sv.get_video_frames_generator(path_to_video)
    tracker = sv.ByteTrack()

    preds = model(path_to_photo, conf=0.41)[0]

    ans = draw_boxes_sv(
        image_path=path_to_photo,
        preds=preds,
        class_name_dict=class_name_dict
    )

    # нужен трекинг - врубай это
    tracking(
        tracker=tracker,
        model=model,
        target_path=path_to_save_record,
        video_info=video_info,
        frames_generator=generator,
        DELAY=2,
        save_record=True
    )