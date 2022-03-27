FROM node:12-slim as node-builder
#ARG TAG_VERSION

WORKDIR /app

# RUN apt update -y && apt install -y git && git clone --depth 1 --branch $TAG_VERSION https://github.com/m0ngr31/DailyNotes.git .
RUN apt update -y && apt install -y git && git clone --depth 1 --branch $TAG_VERSION https://github.com/m0ngr31/DailyNotes.git .

WORKDIR /app/client

ENV PYTHONUNBUFFERED=1
RUN apt install -y python2.7 python-pip g++ make
RUN npm ci
RUN npm rebuild node-sass
RUN npm run build

FROM python:3.8-alpine3.15

ARG TAG_VERSION

WORKDIR /app
COPY --from=node-builder /app /app

RUN \
	apk add build-base libffi-dev && \
	pip install -r requirements.txt && \
	rm -rf /app/client && \
    apk del build-base libffi-dev


EXPOSE 5000
ENTRYPOINT "./run.sh"

