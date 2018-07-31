# Mapproxy on NGINX
Mapproxy running on NGINX with uWSGI and Supervisor

## Introduction
This project aims to fulfill two needs:
1. create a [OGC services](http://www.opengeospatial.org/standards) that are deployable on a scalable infrastructure.
2. create a useable [Docker](https://www.docker.com) base image.

Fulfilling the first need the main purpose is to create an Docker base image that eventually can be run on a platform like [Kubernetes](https://kubernetes.io/).

Regarding the second need, finding a usable Mapproxy Docker image is a challenge. Most image rely on old versions of Mapproxy and or Python.

## What will it do
It will create an Mapproxy application run with a modern web application NGINX that is easy to use. The only thing required to do is to add you own mapproxy.yaml configuration. 

## Components
This stack is composed of the following:
* [Mapproxy](http://mapproxy.org/)
* [NGINX](https://www.nginx.com/)
* [Supervisor](http://supervisord.org/)

### Mapproxy
Mapproxy is the platform that will provide the WMTS, TMS or WMS services based on a OGC source.

### NGINX
NGINX is the web server we use to run Mapproxy as a uWSGI web application. 

### Supervisor
Because we are running 2 processes (Mapproxy uWSGI & NGINX) in a single Docker image we use Supervisor as a controller.

## Usage

### Build
```
docker build -t pdok/mapproxy-nginx .
```

### Run
This image can be run straight from the commandline.
```
docker run -d -p 80:80 --name mapproxy pdok/mapproxy-nginx
```
The prefered way to use it is as a Docker base image for an other Dockerfile, in which the necessay files are copied into the right directory (/usr/local/mapproxy)
```
FROM pdok/mapproxy-nginx

COPY /etc/config/mapproxy.yaml /usr/local/mapproxy/mapproxy.yaml
```
Running the example above will create a service on the url: http:/localhost/mapproxy/.

## Misc
### Why our forked Mapproxy 
Because we want to use the WTMS getFeatureInfo proxy pass, that will be released with 1.12.0.
We did not alter any code, but we have forked from a stable development build. 

### Why NGINX
We would like to run this on a scalable infrastructure like Kubernetes that has it's Ingress based on NGINX. By keeping both the same we hope to have less differentiation in our application stack.

