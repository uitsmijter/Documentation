
![Uitsmijter Documentation](themes/uitsmijter/static/uitsmijter-docs-horizontal-color.png "Uitsmijter Documentation")
![Uitsmijter Documentation](themes/uitsmijter/static/uitsmijter-docs-horizontal-color.svg "Uitsmijter Documentation")

Welcome to the repository of the documentation website located 
at [https://docs.uitsmijter.io](https://docs.uitsmijter.io)

## Contribution
We highly appreciate your contribution to this documentation.
Please feel free to contact us on [Discourse](https://discourse.uitsmijter.io) or on our
[Mastodon](https://social.uitsmijter.io/public/local) instance.

If you find a bug, please [create an issue](https://github.com/uitsmijter/Documentation/issues/new).

## Development

All content resident in the `content` directory as markdown files.
You can edit them locally in a docker environment.

Working live with the documentation files:
```shell
docker run  -ti -v "${PWD}":/build -p 1313:1313 hugo serve --bind 0.0.0.0
```

To create a static docker image:
```shell
./build.sh
```
