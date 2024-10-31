---
title: 'Docker'
weight: 2
---

# Installing Uitsmijter on Docker

Uitsmijter is designed for a Docker-only environment, too. This mode is for small installations 
that does not require a Kubernetes Cluster.

## Prerequisites
Ensure Docker is installed and running on your system.

## Prepare Docker Environment
- [Download Docker Compose Files](https://github.com/uitsmijter/docker-compose/archive/refs/heads/main.zip) from the dedicated repository.

  Obtain [docker-compose.yml](https://raw.githubusercontent.com/uitsmijter/docker-compose/refs/heads/main/docker-compose.yml) 
  and [.env](https://raw.githubusercontent.com/uitsmijter/docker-compose/refs/heads/main/.env)
  files, placing them in the same directory.


## Configure Environment Variables
Edit the `.env` file to customize environment variables like IMAGENAME, TAG, LOG_LEVEL, etc.

**Important variables to change**
| Variable       | Description | 
| -------------- | ----------- |
| ROUTE          | Specify the domains under which Uitsmijter should be accessible. Use [Traefik routing](https://doc.traefik.io/traefik/routing/overview/) syntax. |
| AUTHSERVER_URL | To use Uitsmijter in [interceptor mode](/interceptor), the service definition of your application needs the domain of the Uitsmijter. See Example below. |
| TLS            | If you set `TLS` to true (which is strongly recommended in production use), [Traefik](https://traefik.io) will be instructed to obtain and install a certificate con [LetsEncrypt](https://letsencrypt.org). |
| TAG            | In production, pin the `TAG` to the [latest release](https://github.com/uitsmijter/Uitsmijter/releases) of Uitsmijter. |

## Run the Docker Containers

Run the following command to set up containers for Uitsmijter, Redis, and Traefik:

```shell
$ docker compose up -d
```

## Example

```yaml
  userapp:
    image: nginx:latest
    depends_on:
      - traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.services.userapp.loadbalancer.server.port=80"
      - "traefik.http.routers.userapp.rule=Host(`test.example.com`)"
      - "traefik.http.routers.userapp.tls=${TLS}"
      - "traefik.http.routers.userapp.tls.certresolver=le"
      - "traefik.http.routers.userapp.entrypoints=${LISTEN}"
      - "traefik.http.routers.userapp.service=userapp"
      - "traefik.http.middlewares.testHeader.headers.customrequestheaders.X-Uitsmijter-Mode=interceptor"
      - "traefik.http.middlewares.uitsmijter-auth.forwardauth.address=${AUTHSERVER_URL}/interceptor"
      - "traefik.http.middlewares.uitsmijter-auth.forwardauth.trustForwardHeader=true"
      - "traefik.http.middlewares.uitsmijter-auth.forwardauth.authResponseHeaders=Authorization, X-User-Ident"
      - "traefik.http.routers.userapp.middlewares=uitsmijter-auth@docker"
```

**Explanation**:
This `docker-compose` snippet defines a service, `userapp`, running an Nginx container 
configured with Traefik as a reverse proxy. Here’s a breakdown:

1. **Service Definition**:
  - `userapp` uses the latest Nginx image.
  - It depends on the `traefik` service, ensuring Traefik starts first.

2. **Traefik Labels**:
  - **Routing & Security**: Traefik routes requests to `userapp` at port 80 and applies TLS security with a Let's Encrypt (LE) certificate resolver.
  - **Middleware**: Custom headers and authorization are added via `uitsmijter-auth`, forwarding headers to the Uitsmijter interceptor for handling auth logic.

This setup enables a secure, authenticated reverse-proxy configuration for a containerized application secured by Uitsmijter.

> **Further Reading**
> - For more information, please also consult the [traefik middleware](https://doc.traefik.io/traefik/middlewares/overview/) documentation.
> - For information on the [interceptor mode](/interceptor/interceptor), see the corresponding chapter

**Oauth**
Use the Domain you configured at `AUTHSERVER_URL` (that must be a part of the `ROUTE` definition as well) to configure your 
application to use as the OAuth-Authorisation server.


