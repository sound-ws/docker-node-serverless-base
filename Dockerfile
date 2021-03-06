FROM node:12-stretch

RUN apt-get update && apt-get install -y --no-install-recommends yarn rsync netcat bash

RUN yarn global add serverless

### Configuration variables.

# Environment variables for serverless and nodejs.
# ENV STAGE dev
ENV NODE_ENV development
# ENV LOG_LEVEL debug

# We set these to mock values for local dev (so that AWS client doesnt complain)
ENV AWS_DEFAULT_REGION localhost
ENV AWS_ACCESS_KEY_ID localhost
ENV AWS_SECRET_ACCESS_KEY localhost

# This is where we volume mount shared stuff
ENV NODE_PATH /var/www/

### End of configuration variables.

WORKDIR /var/www/app/

# Install ffmpeg so that it mirrors the way it would run in a lambda layer
RUN mkdir /workdir && \
  cd /workdir && \
  curl -O https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz

RUN cd /workdir && \
  tar xfa ffmpeg-git-amd64-static.tar.xz && \
  rm ffmpeg-git-amd64-static.tar.xz && \
  mv ffmpeg-git-*-amd64-static /tmp/ffmpeg && \
  mkdir -p /opt/bin/ && \
  mv /tmp/ffmpeg/ffmpeg /opt/bin/ && \
  mv /tmp/ffmpeg/ffprobe /opt/bin/

COPY bin/lame /opt/bin/lame
COPY bin/sox /opt/bin/sox

ENV FFMPEG_BIN_PATH /opt/bin/ffmpeg
ENV FFPROBE_BIN_PATH /opt/bin/ffprobe
ENV LAME_BIN_PATH /opt/bin/lame
ENV SOX_BIN_PATH /opt/bin/sox

CMD ['yarn', 'start']