FROM node:12-slim as node-builder
ARG TAG_VERSION

WORKDIR /app

RUN apt update -y && apt install -y git && git clone --depth 1 --branch $TAG_VERSION https://github.com/m0ngr31/DailyNotes.git .

WORKDIR /app/client

ENV PYTHONUNBUFFERED=1
RUN apt install -y python3 g++ make
# RUN ln -sf python3 /usr/bin/python
RUN npm ci
RUN npm rebuild node-sass
RUN npm run build
RUN npm prune --production
RUN rm -rf tests

FROM python:3.8-alpine3.15

ARG TAG_VERSION

WORKDIR /app

RUN \
	apk add git && git clone --depth 1 --branch $TAG_VERSION https://github.com/m0ngr31/DailyNotes.git . && \
	apk add build-base libffi-dev && \
	pip install -r requirements.txt && \
	rm -rf /app/client && \
    apk del build-base libffi-dev git

COPY --from=node-builder /app/client /app/client

EXPOSE 5000
ENTRYPOINT "./run.sh"

