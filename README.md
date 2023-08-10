[TOC]

# 1. Build multiplatform docker  {#r_build_docker} ###

## 1.1. Requirements  {#r_docker_req} ####

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

Check that everything is installed with

```bash
./scripts/check-qemu.sh
```

## 1.2. Build multiplatform python image for old OS {#r_docker_push} ###

Log to dockerhub :

```bash
docker login
```

Warning :

- first build of ARM image may take up to 2 hours

```bash
  docker buildx build -t username/python3-glibc2.24:tag . -f dockerfiles/python-build.dockerfile --progress=plain --platform=linux/amd64,linux/arm/v7,linux/arm64 --push
```

## 1.3. Déboguer l'image ####

Run an image :

```bash
docker run --name test-debug --entrypoint /bin/sleep pich02/python3-glibc2.24:3.10.12 infinity
```

Connecte to it with :

```bash
docker exec -it $(docker ps -aqf "name=test-debug") /bin/bash