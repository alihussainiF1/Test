FROM ubuntu:18.04

LABEL ALI HUSSAINI

RUN apt-get update
RUN apt-get install -y python 

ADD hello.py /
CMD ["python","./hello.py"]
