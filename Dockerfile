FROM nikolaik/python-nodejs:python3.8-nodejs12-alpine

ARG TAG_VERSION

RUN mkdir /app
WORKDIR /app

RUN apk add git && git clone --depth 1 --branch $TAG_VERSION https://github.com/m0ngr31/DailyNotes.git .

RUN apk add build-base libffi-dev

RUN \
  cd /app && \
  pip install -r requirements.txt && \
  chmod +x run.sh && \
  chmod +x verify_env.py && \
  chmod +x verify_data_migrations.py

RUN \
  cd /app/client && \
  npm ci && \
  npm rebuild node-sass && \
  npm run build

EXPOSE 5000
ENTRYPOINT "./run.sh"

