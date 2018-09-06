# Warp 10 Docker image

## Quick reference

- **Where to get help:** [Warp10.io](https://warp10.io), [Warp 10 users group](https://groups.google.com/group/warp10-users)

- **Warp 10 Platform repository:** [https://github.com/cityzendata/warp10-platform](https://github.com/cityzendata/warp10-platform)

- **Warp 10 Docker repository:** [https://github.com/cityzendata/warp10-docker](https://github.com/cityzendata/warp10-docker)

- **Maintained by:** [Cityzen Data](http://www.cityzendata.com/)

## What is Warp 10

The Warp 10 Platform is designed to collect, store and manipulate sensor data. Sensor data are ingested as sequences of measurements (also called time series). The Warp 10 Platform offers the possibility for each measurement to also have spatial metadata specifying the geographic coordinates and/or the elevation of the sensor at the time of the reading. Those augmented measurements form what we call Geo Time Series™ (GTS).
> [Warp10.io](https://warp10.io)

![Warp 10 logo](https://cdn-images-1.medium.com/max/800/0*ajCaRkg8gvcsZtXl.png)

## How to use this image

The easiest way to setup the Warp 10 platform is to use [Docker](https://www.docker.com/). Officials builds are available on [Docker Store](https://store.docker.com/community/images/warp10io/warp10) containing:

- The Warp 10 platform for storing and analysing Geo Time Series™
- Quantum:  a web application aiming to allow users to interact with the platform
- Sensision: a service for monitoring Warp 10 platform metrics

### Start a Warp 10 instance

Start your image binding the external ports `8080` for Warp 10 and `8081` for Quantum:

```console
docker run -d -p 8080:8080 -p 8081:8081 warp10io/warp10:latest
```

You can set the image version with warp10io/warp10:`X.Y.Z`.

### Mapping volume for persistancy

Docker containers are easy to delete. If you delete your container instance, you will lose the Warp 10 storage and configuration. You may want to add a volume mapping to the containers `/data` folder.

```console
docker run -d -p 8080:8080 -p 8081:8081 --volume=/var/warp10:/data warp10io/warp10:latest
```

In this example, you bind the container internal data folder `/data` to your local folder `/var/warp10`.
You *must* use the same `--volume` option in all your other docker commands on Warp 10 image.

### Working in memory

You can add `-e IN_MEMORY=true` to pop an in-memory Warp 10 instance.

```console
docker run -d -p 8080:8080 -p 8081:8081 -e IN_MEMORY=true warp10io/warp10:latest
```

### Continuous Integration

A 'Continuous Integration' version is available on Dockerhub with the 'ci' suffix.

This version embeds a pair of READ/WRITE tokens named respectively 'readTokenCI', 'writeTokenCI'.

Example:
```console
[ 'readTokenCI' '~.*' {} NOW -1 ] FETCH // Retrieve the last point for all GTS
```

## Getting Tokens

The Warp 10 platform is built with a robust security model that allows you to have a tight control of who has the right to write and/or read data. The model is structured around the [concepts](http://www.warp10.io//introduction/concepts) of `data producer`, `data owner` and `application`, and `WRITE` and `READ` tokens.

Otherwise, for the purposes of this setup, you need to generate write and read tokens for a test application for a test user that is both the producer and the owner of the data. In order to interact with the user/token/application system, you need an interactive access to Warp 10's [Worf](http://www.warp10.io/tools/worf) component. You get it by executing `warp10-standalone.sh worf` on the running container.

First, get the container id for your running Warp 10 image:

```console
$ docker ps
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS                              NAMES
dc6e541e79d8        warp10io/warp10:1.2.9   "/bin/sh -c ${WARP10_"   55 seconds ago      Up 55 seconds       0.0.0.0:8080-8081->8080-8081/tcp   hopeful_einstein
```

Then run `docker exec` to run Worf on that container id:

```console
docker exec -u warp10 -it dc6e541e79d8 warp10-standalone.sh worf appName ttl(ms)
```

Where `appName` is the choosen application name and `ttl(ms)` the time-of-live of the token in milliseconds.

For example, let's generate a pair of tokens for an application called `test`, with one year of livespan:

```console
$ docker exec -u warp10 -it dc6e541e79d8 warp10-standalone.sh worf test 31536000000
default options loaded from file:/opt/warp10/etc/.conf-standalone.conf.worf
{"read":{"token":"1Uol41cpikTrY5IGUgtwHG4kZ0puh5clethlBuq2Qjs5kWaRhvQOsHKHXsnpH5.lU7GePUIZowFTblA5lkeuDeqFZGgzrmVp1RTWghrA.f5ahLbUVO0S2.","tokenIdent":"ef8cd2a9e3e15fd9","ttl":31536000000,"application":"test","owner":"d7d310cf-254e-4065-87ae-47e83a050ab3","producer":"d7d310cf-254e-4065-87ae-47e83a050ab3"},"write":{"token":"yCY6J7jKJTWgQVrNJpsgPav7ubqiZIlx0jtDibNYO5cJNzq8EziSGOszoXGmFgXFnXbI_Yq3WXg53ry4qXkWU4vkjK9tmE3cWccPbzWvo9c","tokenIdent":"cc3a63e7b7d5ca1b","ttl":31536000000,"application":"test","owner":"d7d310cf-254e-4065-87ae-47e83a050ab3","producer":"d7d310cf-254e-4065-87ae-47e83a050ab3"}}
```

## Testing the container

To test the running container, push a single GTS containing one data in the platform using your WRITE token.

```console
curl -v -H 'X-Warp10-Token: WRITE_TOKEN' --data-binary "1// test{} 42" 'http://127.0.0.1:8080/api/v0/update'
```

If everything is OK, you should receive a HTTP 200

> When using Docker on Mac OS or Windows, there is no binding between Warp 10 API address and the host (docker is runned throw a Virtual Machine). To reach Warp 10 you need to replace 127.0.0.1 by the real Ip address of the container. To get it, use a simple `docker-machine ip default>`, the container address is also shown in the Settings/Ports page of your container. If you used the shared volume between the container and the host, you can access to the virtual machine using `docker-machine ssh default>` and inspect the repertory `/var/warp10`. Don't hesitate to check on [docker-machine documentation](https://docs.docker.com/machine/).

Get this data using your READ tokens.

```console
curl -v --data-binary "'READ_TOKEN' 'test' {} NOW -1 FETCH" 'http://127.0.0.1:8080/api/v0/exec'
```

If everything is OK, you should receive a HTTP 200 OK with your datapoint in JSON format.

A full [getting started](http://www.warp10.io/getting-started/) is available to guide your first steps into Warp 10.

## Using Quantum

[Warp 10's Quantum](http://www.warp10.io/tools/quantum) is a web application aiming to allow users to interact with the platform in an user-friendly way, offering an alternative to command-line interaction.

> A standalone version of Quantum is packaged in the Docker image you have just installed, listening on the port 8081. In a Linux system (with binding between Warp 10 API address and the host) you can access Quantum at `127.0.0.1:8081`. In Mac OS or Windows, there is no binding between Warp 10 API address and the host, you need to replace 127.0.0.1 by the real Ip address of the container as explained in the precedent section.

![Quantum](http://www.warp10.io/img/getting-started/quantum-warpscript.png)

## Build the image

If you want to build your own Warp 10 image, clone the Warp 10 docker repository:

```console
git clone https://github.com/cityzendata/warp10-docker.git
```

Execute `docker build` inside your local copy:

```console
cd warp10-docker
docker build -t myrepo/warp10:x.y.z .
```
