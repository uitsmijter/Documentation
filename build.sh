#!/bin/bash

set -e
set -o pipefail

IMAGE_TAG="documentation"

## Parsing parameters to overwrite some default values
PARAMS=""
while (( "$#" )); do
  case "$1" in
    -t|--tag)
      IMAGE_TAG="${2}"
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"

# COMPILE SCSS TO CSS
docker build -t sass -f deployment/sass.dockerfile .
for SASS_SOURCE in main mobile print
do
  docker run -ti --rm -v ${PWD}/resources:/build sass sass sass/${SASS_SOURCE}.scss ${SASS_SOURCE}.css
  mv -f ./resources/${SASS_SOURCE}.{css,css.map} ./themes/uitsmijter/static
done

# CREATING WOFF FONT FROM TTF
docker build -t woff-tools -f deployment/woff.dockerfile .
for TTF in $(ls ./themes/uitsmijter/static/fonts/{Bebas_Neue,Inconsolata,Inconsolata/**,Source_Sans_Pro}/*.ttf); do
	docker run --rm -v ${PWD}:/build woff-tools ${TTF};
done

# BUILD THE SITE WITH HUGO
mkdir ./public
docker build -t hugo -f deployment/hugo.dockerfile .
docker run  -ti --rm -v "${PWD}:/build" hugo

# BUILD THE FINAL IMAGE
docker build -t ${IMAGE_TAG} -f deployment/nginx.dockerfile .
