FROM python:3.10

#Author : Becode5
#Date : 21/11/2022

RUN mkdir app
RUN mkdir app/logs

WORKDIR /app

COPY twtserver /app

RUN pip3 install -r requirements.txt

CMD ["python3", "twtserver.py"]