import io
import os
import base64
import sys
parent_dir = os.path.abspath(os.path.join(os.path.dirname(__file__)))
ml = parent_dir + '/ml/'
sys.path.insert(0, ml)
from PIL import Image
from time import sleep
from typing import List
from zipfile import ZipFile, ZIP_DEFLATED
import json
from ultralytics import YOLO, RTDETR
import supervision as sv
from cv2 import imwrite
from pydantic import BaseModel
from fastapi import BackgroundTasks, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse

from ml.main import seed_everything, draw_boxes_sv, tracking, count_classes


app = FastAPI(title="Обнаружение дефектов на трубах")
model = None
class_name_dict = None


class Image64(BaseModel):
    files: List[str]
    files_names: List[str]


class Video(BaseModel):
    file: str


class RTSP(BaseModel):
    url: str


origins = [
    "*",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*",],
    allow_headers=["*",],
)


@app.on_event("startup")
def startup_event():
    global model, class_name_dict
    seed_everything(seed=42)
    # model = RTDETR('ml/best.pt')
    model = YOLO('ml/yolov8_s.pt')
    class_name_dict = model.model.names
    model.fuse()


def to_zip(path: str):
    zip_io = io.BytesIO()
    with ZipFile(zip_io, mode='w', compression=ZIP_DEFLATED) as temp_zip:
        for root, _, files in os.walk(path):
            for fileName in files:
                temp_zip.write(os.path.join(root, fileName), fileName) # первый параметр отвечает за то, какой файл выбрать, а второй, как он будет называться
    return StreamingResponse(
        iter([zip_io.getvalue()]), 
        media_type="application/x-zip-compressed", 
        headers = { "Content-Disposition": f"attachment; filename=results.zip"}
    )


def remove_file(path: str) -> None:
    sleep(10)
    for f in os.listdir(path):
        os.remove(os.path.join(path, f))


@app.post('/photo')
def image_detection(file: Image64, background: BackgroundTasks):
    path_files = parent_dir + '/photos/'
    images = file.files
    names = file.files_names
    json_ans = {"data": []}
    for i, file in enumerate(images):
        image_as_bytes = str.encode(file)  # convert string to bytes
        img_recovered = base64.b64decode(image_as_bytes)  # decode base64string
        image = Image.open(io.BytesIO(img_recovered))
        path_to_photo = path_files + 'original/' + f"{names[i]}"
        _ = image.save(path_to_photo)
        
        preds = model(path_to_photo, conf=0.41)[0]
        ans = draw_boxes_sv(
            image_path=path_to_photo,
            preds=preds,
            class_name_dict=class_name_dict
        )

        types, count_defects = count_classes(preds, class_name_dict)
        autotypes = ''
        for key, value in types.items():
            if value > 0:
                autotypes += f"{key} - {value}\n"
        
        imwrite(path_files + 'results/' + f"boxed_image-{names[i]}", ans)
        json_ans['data'].append({'id': i + 1, 'image_path': names[i], 'autotype' : autotypes, 'count': count_defects})
    with open(path_files + 'results/' + 'data.txt', 'w') as outfile:
        json.dump(json_ans, outfile)
    background.add_task(remove_file, path_files + '/results/')
    return to_zip(path_files + 'results/')


@app.post('/video')
def video_traking(input: Video):
    video_info = sv.VideoInfo.from_video_path(input.file)
    generator = sv.get_video_frames_generator(input.file)
    tracker = sv.ByteTrack()
    new_name = os.path.basename(input.file)
    output_path_file = parent_dir + '/videos/results/' + f"{new_name}"
    tracking(
        tracker=tracker,
        model=model,
        target_path=output_path_file,
        video_info=video_info,
        frames_generator=generator,
        DELAY=2,
        save_record=True
    )
    # json_ans = {"data": [{'id': 1, 'image_path': input.file, 'autotype' : 'car', 'pollution': 57, 'count': 3}]}
    # with open(parent_dir + '/videos/results/' + 'data.txt', 'w') as outfile:
    #     json.dump(json_ans, outfile)
    return to_zip(parent_dir + '/videos/results/')


@app.post('/active_learning')
def active_learning(input: RTSP):
    print(input.url)
    return {"message": "Something"}
