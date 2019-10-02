FROM debian:stretch-slim AS build
RUN apt-get update
RUN apt-get install -y curl 
RUN apt-get install -y git
WORKDIR /build
RUN curl -L https://github.com/gohugoio/hugo/releases/download/v0.57.2/hugo_0.57.2_Linux-64bit.tar.gz --output hugo.tar.gz
RUN tar -xvzf hugo.tar.gz
COPY . /build
RUN ./hugo

FROM nginx:latest
COPY --from=build /build/public/ /usr/share/nginx/html
