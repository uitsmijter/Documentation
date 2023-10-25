# Uitsmijter Documentation

## About

This is the website hosted on [https://docs.uitsmijter.io](https://docs.uitsmijter.io)

## Edit content
All content resident in the `content` directory as markdown files.

## Development

Create the WebContainer
```shell
./build.sh
```

Working with hugo
```shell
docker run  -ti -v "${PWD}":/build -p 1313:1313 hugo serve --bind 0.0.0.0
```
