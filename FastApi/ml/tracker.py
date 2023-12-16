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
        save_record: bool = True
):
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
            if save_record:
                sink.write_frame(frame)
