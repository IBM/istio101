# Workshop Extra Credit

This lab makes use of alot of the things done in the previous lab. If you haven't done it yet. Complete [lab part 1 here](overview/#lets-get-started)

## Step 1

[Install Docker](https://docs.docker.com/install/)

* MacOS [Download Docker Desktop from Docker Hub](https://hub.docker.com/editions/community/docker-ce-desktop-mac)
* Linux
  * CentOS Install using this [Document](https://docs.docker.com/install/linux/docker-ce/centos/)
  * Debian Install using this [Document](https://docs.docker.com/install/linux/docker-ce/debian/)
  * Fedora Install using this [Document](https://docs.docker.com/install/linux/docker-ce/fedora/)
  * Ubuntu Install using this [Document](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
* Windows [Download Docker Desktop from Docker Hub](https://hub.docker.com/editions/community/docker-ce-desktop-windows)

  Docker Desktop requires Windows 10 Professional or Enterprise. For other versions of windows download [Docker Toolbox](https://docs.docker.com/toolbox/overview/)

## Step 2

Check Docker installation.

```bash
$ docker version

Client: Docker Engine - Community
 Version:           18.09.1
 API version:       1.39
 Go version:        go1.10.6
 Git commit:        4c52b90
 Built:             Wed Jan  9 19:33:12 2019
 OS/Arch:           darwin/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          18.09.1
  API version:      1.39 (minimum version 1.12)
  Go version:       go1.10.6
  Git commit:       4c52b90
  Built:            Wed Jan  9 19:41:49 2019
  OS/Arch:          linux/amd64
  Experimental:     true
```

Your output may be a little different.

## Step 3

[Create Docker Hub account.](https://hub.docker.com/signup) Save the docker hub login info. We will use that in the next step.

## Step 4

Login to docker from terminal

```bash
$ docker login

Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: <YOUR-DOCKER-USERNAME>
Password:
Login Succeeded
```

## Step 5

For this next part, you will need a hosted MongoDB instance. IBM Cloud Lite account can not provision a MongoDB instance. So ask you instructor for a trial account promo code or use any other hosted MongoDB instance. You can even find some with a small free tier.

Copy your mongo connection string. It should be in the form

```bash
mongodb://<USERNAME>:<PASSWORD>@<HOST>:<PORT>/<DATABASE_NAME>
```

In each of the microservice folder there is a file names `.env.example`. Rename the file to `.env`. Update the variable `MONGO_URL` with your MongoDB connection string.

## Step 6

We will now build the docker image.

```bash
docker build -f Dockerfile -t <YOUR-DOCKER-USERNAME>/<image-name>:<image-tag>
```

For example, for `portal` my docker build instruction was like this:

```bash
docker build -f Dockerfile -t moficodes/innovate-portal:v1.0.1-alpine .
```

Once image is built you can check it was created.

```bash
$ docker images | grep moficodes/innovate-portal

moficodes/innovate-portal                v1.0.1-alpine       c958e755e877        About an hour ago   156MB
```

## Step 7

Push the image to docker hub image registry

```bash
docker push <YOUR-DOCKER-USERNAME>/<image-name>:<image-tag>
```

Keep the image name and tag name stored. We will make use of them in the next step.

Once the image is pushed you should be able to see it in your docker hub repository.

Do the same for all 7 microservices.

## Setp 8

In each of the microservices `folder/chart/innovate-<microservice>/values.yaml` file update the image with your docker image.

For example for portal. Update the `portal/chart/innovate-portal/values.yaml` file.

Change the repository to `<YOUR-DOCKER-USERNAME>/<image-name>` and tag to `<image-tag>`

Once all 7 microservice helm charts have been updated, we can get to deploying them. The helm charts deployment is same as [Lab Part I](overview/deploy-innovate-digital-bank.md)

