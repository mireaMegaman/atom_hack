FROM python:3.9

RUN apt-get update && apt-get install ffmpeg libsm6 libxext6  -y

WORKDIR /FastApi

COPY ./requirements.txt /FastApi/requirements.txt

RUN pip install -r /FastApi/requirements.txt

COPY . /FastApi
