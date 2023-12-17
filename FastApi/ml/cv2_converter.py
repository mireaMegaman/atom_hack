import cv2
import numpy


def draw_boxes(path_to_image: str, yolo_predict) -> numpy.ndarray:
    """
    Get the original image and return image with visualized bboxes (coord from yolo v8 predict)
    :param path_to_image: str
    :param yolo_predict: yolo v8 results
    :return: array with visualized bboxes
    """
    image = cv2.imread(path_to_image)
    height, width, _ = image.shape

    try:
        for object_ in yolo_predict[0].boxes.xyxyn:
            x_min, y_min, x_max, y_max = object_
            x_min = int(x_min * width)
            y_min = int(y_min * height)
            x_max = int(x_max * width)
            y_max = int(y_max * height)
            cv2.rectangle(image, (x_min, y_min), (x_max, y_max), (0, 255, 0), 3)  # array here

        return image
    except:
        return image


def draw_boxes_from_list(image_path1, boxes_1, labels1):
    image = cv2.imread(image_path1)
    height, width, _ = image.shape
    print(height, width)

    if boxes_1 is not None:
        for object_, label_ in zip(boxes_1, labels1):
            x_min, y_min, x_max, y_max = object_
            x_min = int(x_min * width)
            y_min = int(y_min * height)
            x_max = int(x_max * width)
            y_max = int(y_max * height)
            cv2.rectangle(image, (x_min, y_min), (x_max, y_max), (0, 255, 0), 3)  # array here

    return image
