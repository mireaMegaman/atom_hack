import io
import os
import base64
from PIL import Image
from time import sleep
from typing import List
from random import choice
from zipfile import ZipFile, ZIP_DEFLATED
import json
from ultralytics import YOLO, RTDETR
from cv2 import imwrite
from pydantic import BaseModel
from fastapi import BackgroundTasks, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse

from ml.main import seed_everything, draw_boxes

parent_dir = os.path.abspath(os.path.join(os.path.dirname(__file__)))
ml = parent_dir + '/ml/'
app = FastAPI(title="Обнаружение дефектов на трубах")
model = None
CLASS_NAMES_DICT = None


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
    global model, CLASS_NAMES_DICT
    seed_everything(seed=42)
    model = RTDETR('ml\\best.pt')
    CLASS_NAMES_DICT = model.model.names
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
    type_defects = ['Passenger car', 'Motorbike', 'Truck']
    json_ans = {"data": []}
    for i, file in enumerate(images):
        image_as_bytes = str.encode(file)  # convert string to bytes
        img_recovered = base64.b64decode(image_as_bytes)  # decode base64string
        image = Image.open(io.BytesIO(img_recovered))
        _ = image.save(path_files + 'original/' + f"{names[i]}")
        preds = model(path_files + 'original/' + f"{names[i]}")
        ans = draw_boxes(preds)
        imwrite(path_files + 'results/' + f"boxed_image-{names[i]}", ans)
        json_ans['data'].append({'id': i + 1, 'image_path': names[i], 'autotype' : [''], 'pollution': '108, 36', 'count': 3})
    with open(path_files + 'results/' + 'data.txt', 'w') as outfile:
        json.dump(json_ans, outfile)
    background.add_task(remove_file, path_files + '/results/')
    return to_zip(path_files + 'results/')


# @app.post('/video')
# def video_traking(input: Video):
#     json_ans = {"data": [{'id': 1, 'image_path': input.file, 'autotype' : 'car', 'pollution': 57, 'count': 3}]}
#     output_path_file = parent_dir + '/videos/results/' + f"result_{input.file}.mp4"
#     tracking(
#         model=model,
#         conf=0.4,
#         input_filename=input.file,
#         output_filename=output_path_file
#     )
#     with open(parent_dir + '/videos/results/' + 'data.txt', 'w') as outfile:
#         json.dump(json_ans, outfile)
#     return to_zip(parent_dir + '/videos/results/')


@app.post('/active_learning')
def active_learning(input: RTSP):
    print(input.url)
    return {"message": "Something"}
