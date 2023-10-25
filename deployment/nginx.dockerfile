FROM nginx:alpine
MAINTAINER aus der Technik

ADD ./public /usr/share/nginx/html/

CMD ["nginx", "-g", "daemon off;"]
