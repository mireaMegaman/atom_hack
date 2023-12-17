import supervision as sv
from tqdm.auto import tqdm
import cv2


def tracking(
        tracker,
        model,
        target_path,
        video_info,
        frames_generator,
        DELAY: int = 2,
        save_record: bool = False
):
    """
    Функция для запуска object tracking (отслеживания дефектов по видео, а не по фото)
    :param tracker: Трекер для состыковки кадров
    :param model: Модель для предсказания по фотографии
    :param target_path: Путь для записи уже размеченного видео
    :param video_info: Информация о видео (кадры в секунду, ширина и высота)
    :param frames_generator: итератор, разделяющий и "выбрасывающий" кадры видео
    :param DELAY: Частота прореживания кадров (допустим, если DELAY = 2, то будет браться каждый 2-ой кадр)
    :param save_record: Записывать ли размеченное видео
    :return: None
    """
    assert DELAY >= 1, "Для прореживания кадров величина выборки кадров должна быть >= 1."

    count = 0
    box_annotator = sv.BoxAnnotator(
        thickness=2,
        text_thickness=2,
        text_scale=1
    )

    with sv.VideoSink(target_path=target_path, video_info=video_info) as sink:
        for frame in tqdm(frames_generator):
            count += 1
            if count % DELAY != 0:
                continue

            result = model(frame)[0]
            detections = sv.Detections.from_ultralytics(result)
            detections = tracker.update_with_detections(detections)
            labels = [f"{model.names[class_id]} {confidence:0.2f}" for _, _, confidence, class_id, _ in detections]
            frame = box_annotator.annotate(
                scene=frame,
                detections=detections,
                labels=labels
            )

            # надо на кадр нарисовать bbox и вывести
            cv2.imshow(frame)

            if save_record:
                sink.write_frame(frame)

            if cv2.waitKey(0):
                break

    cv2.destroyAllWindows()
