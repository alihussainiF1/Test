FROM ubuntu:18.04

LABEL ALI HUSSAINI

RUN apt-get update
RUN apt-get install -y python 

ADD hello.py /home/openplaytech/hello.py

CMD ["/home/openplaytech/hello.py"]
ENTRYPOINT ["python"]
