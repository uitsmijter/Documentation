---
title: 'Logging'
weight: 4
---

# Logging

The Uitsmijter authorisation server logs in different levels and formats. As default, it logs in `INFO` and plain
strings onto the
console but ndjson format is also supported.

> The default might change in the future because ndjson is more commonly used.

## Setting the level

The following levels are available:

| Name     | Description                                                                                                     |
|----------|-----------------------------------------------------------------------------------------------------------------|
| trace    | Appropriate for messages that contain information normally of use only when tracing the execution of a program. |
| debug    | Appropriate for messages that contain information normally of use only when debugging a program.                |
| info     | Appropriate for informational messages.                                                                         |
| notice   | Appropriate for conditions that are not error conditions, but that may require special handling.                |
| warning  | Appropriate for messages that are not error conditions, but more severe than notice.                            |
| error    | Appropriate for error conditions.                                                                               |
| critical | Appropriate for critical error conditions that usually require immediate attention.                             |

Set the `LOG_LEVEL` as an environment variable to get the logs of the level of detail you need.

If you run Uitsmijter in local development mode, you can set the environment variable `LOG_LEVEL` in the file `.env`.

```shell
LOG_LEVEL=debug
```

Installing on Kubernetes via [Helm](http://helm.sh) you set the environment variable in a `Values.yaml`. Please have a
look at the [deployment documentation](deployment)

## Setting the format

Those formats are available

| Name    | Description                                                   |
|---------|---------------------------------------------------------------|
| console | Logs a plain log string in the format of `[ level ] Message`. |
| ndjson  | Logs detailed information as a one line json string.          |

Set the `LOG_FORMAT` as environment variable to log in the needed form.

If you run Uitsmijter in local development mode, you can set the environment variable `LOG_LEVEL` in the file `.env`.

```shell
LOG_LEVEL=debug
```

Installing on Kubernetes via [Helm](http://helm.sh) you set the environment variable in a `Values.yaml`. Please have a
look at the [deployment documentation](deployment) and the [quick start guide](/general/quickstart).
