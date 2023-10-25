FROM ubuntu

RUN apt update \
    && apt upgrade -y \
    && apt install -y ca-certificates  \
    && apt install -y woff-tools woff2

ADD deployment/scripts/convert.sh /convert.sh

WORKDIR /build
ENTRYPOINT ["/convert.sh"]
