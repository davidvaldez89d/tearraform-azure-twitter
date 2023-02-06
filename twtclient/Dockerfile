FROM python:3.10

#Author : Becode5
#Date : 21/11/2022

RUN mkdir app

WORKDIR /app

COPY twtclient /app

RUN apt-get update && apt-get upgrade -y
RUN apt-get install openjdk-11-jdk -y
RUN pip3 install -r requirements.txt

CMD ["python", "twtclient.py"]