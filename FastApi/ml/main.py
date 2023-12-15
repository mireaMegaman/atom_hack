import cv2
from ultralytics import RTDETR, YOLO
from ml.helper import create_video_writer
import datetime
from typing import Union, Optional

import os
import torch
import random
import numpy as np


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


def tracking(
        model: Union[RTDETR, YOLO],
        input_filename: str,
        output_filename: Optional[str],
        conf: float
) -> None:
    """
    Video object tracking function
    :param model: object detection model
    :param input_filename: name + format for input (example: in.mp4)
    :param output_filename: name + format for output (example: out.mp4)
    :param conf: confidience for object selection (model parameter)
    :return: None
    """
    assert 0 < conf <= 1, "Confidience must be greater than 0 and less than 1"
    if output_filename is None:
        filename, file_format = input_filename.split[0], input_filename.split[-1]
        output_filename = f'{filename}_output.{file_format}'

    video_cap = cv2.VideoCapture(input_filename) # 0 for webcams
    writer = create_video_writer(video_cap, output_filename)

    while True:
        start = datetime.datetime.now()
        ret, frame = video_cap.read()

        if not ret:
            break

        detections = model.track(frame, conf=conf, persist=True, tracker="bytetrack.yaml")[0]
        """for data in detections.boxes.data.tolist():
            confidence = data[4]

            if float(confidence) < conf:
                continue

            xmin, ymin, xmax, ymax = int(data[0]), int(data[1]), int(data[2]), int(data[3])
            cv2.rectangle(frame, (xmin, ymin), (xmax, ymax), (255, 0, 0), 2)"""
        print(type(detections))
        res_plotted = detections.plot()
        end = datetime.datetime.now()
        total = (end - start).total_seconds()
        print(f"Time to process 1 frame: {total * 1000:.0f} milliseconds")

        """fps = f"FPS: {1 / total:.2f}"
        cv2.putText(frame, fps, (50, 50),
                    cv2.FONT_HERSHEY_SIMPLEX, 2, (0, 0, 255), 8)"""

        # cv2.imshow("Frame", frame)
        cv2.imshow("Frame", res_plotted)
        writer.write(res_plotted)
        if cv2.waitKey(0):
            break

    video_cap.release()
    writer.release()
    cv2.destroyAllWindows()


if __name__ == '__main__':
    seed_everything(seed=42)
    model = YOLO('./yolov8x.pt')
    model.fuse()
    tracking(
        model=model,
        conf=0.4,
        input_filename="test.mp4",
        output_filename="byte_output.mp4"
    )