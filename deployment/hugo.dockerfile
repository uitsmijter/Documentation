FROM ubuntu

RUN apt update \
    && apt upgrade -y \
    && apt install -y ca-certificates curl wget  \
    && apt install -y hugo

WORKDIR /build
ENTRYPOINT ["hugo"]
