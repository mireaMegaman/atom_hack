import os
import cv2
import torch
import random
import numpy as np

from ultralytics import RTDETR, YOLO
import supervision as sv
from tracker import tracking

from typing import Dict, List, Tuple


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


def calc_center_dot(preds) -> List[Tuple[float, float]]:
    """
    Считает коордианты центров всех bbox в предсказании
    :param preds: предсказания модели по кадру
    :return: Координаты центров всех найденных bbox
    """
    ans = []
    for tensor in preds.boxes.xyxy:
        xyxy = tensor.tolist()
        x = int((xyxy[0] + xyxy[2]) / 2)
        y = int((xyxy[1] + xyxy[3]) / 2)
        ans.append((x, y))

    return ans


def draw_boxes_sv(
        image_path: str,
        preds,
        class_name_dict: Dict[int, str]
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
        thickness=3,
        text_thickness=2,
        text_scale=1
    )

    dot_annotator = sv.DotAnnotator(radius=6)

    coordinates = calc_center_dot(preds)

    detections = sv.Detections.from_ultralytics(preds)
    labels = [f"{class_name_dict[class_id]}; ({cords[0]}; {cords[1]})" for cords,( _, _, confidence, class_id, _) in zip(coordinates, detections)]
    annotated_image = box_annotator.annotate(
        image,
        detections=detections,
        labels=labels
    )

    annotated_image = dot_annotator.annotate(
        annotated_image,
        detections=detections,
    )

    return annotated_image


def count_classes(preds, class_name_dict):
    """
    Подсчет количества дефектов на кадре каждого вида
    :param preds: предсказания YOLO / RTDETR по фотографии
    :param class_name_dict: наименование классов, как они записаны в модели
    :return: Dict[str, int], количество обьектов каждого класса
    """
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