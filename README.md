[TOC]

# 1. Build multiplatform docker  {#r_build_docker} #

## 1.1. Requirements  {#r_docker_req} ##

```bash
sudo apt-get install -y docker-ce
sudo apt-get install -y qemu qemu-user-static
sudo apt-get install -y binfmt-support
docker buildx create --use --name mybuilder
```

Add in your .docker/config.json

```
{
    "experimental": "enabled"
}
```

## 1.2. Build multiplatform python image for old OS {#r_docker_push} ##

Log to dockerhub :

```bash
docker login
```

Warning :

- first build of ARM image may take up to 2 hours

```bash
TAG=3.11.9
docker buildx build -t pich02/python3-glibc2.24:$TAG . -f python-build.dockerfile --progress=plain --platform=linux/amd64,linux/arm/v7,linux/arm64 --push

```

## 1.3. Build multi-arch scip ##

put scip-9.0.0.tgz source inside packages directory

```bash
TAG=9.0.0
sudo docker buildx build -t pich02/scip-multi-arch:$TAG . -f scip-build.dockerfile --progress=plain --platform=linux/amd64,linux/arm/v7,linux/arm64 --push
```

## 1.4. Build python3 with scip ##

```bash
TAG=3.11.9
docker buildx build -t pich02/python3-glibc2.24:${TAG}-scip . -f python-scip.dockerfile --progress=plain --platform=linux/amd64,linux/arm/v7,linux/arm64 --push
```


## 1.5. Déboguer l'image ##

Run an image :

```bash
docker run --name test-debug --entrypoint /bin/sleep pich02/python3-glibc2.24:3.11.9 infinity
```

Connect to it with :

```bash
docker exec -it $(docker ps -aqf "name=test-debug") /bin/bash
```

## 1.6. troubleshooting ##

### 1.6.1. GCP compute engine ###

Docker build failed to "apt update"

check mtu 

```bash
ip addr | grep mtu
```

mtu of enx3 and docker0 must be the same if not added :

{
  "mtu": 1460
}

to /etc/docker/daemon.json

