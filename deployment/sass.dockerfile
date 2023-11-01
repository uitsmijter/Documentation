FROM node:20-bullseye

RUN apt update \
    && apt upgrade -y \
    && apt install -y ca-certificates \
    && apt install -y npm

RUN npm install -g sass

WORKDIR /build
ENTRYPOINT []
