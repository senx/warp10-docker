# Warp&nbsp;10™ Docker image

## Quick reference

- **Where to get help:**
  - Web site: https://warp10.io
  - Google group: https://groups.google.com/group/warp10-users
  - Warp&nbsp;10 community slack: https://lounge.warp10.io/
  - Stack Overflow: https://stackoverflow.com/questions/tagged/warp10

- **Warp&nbsp;10 Platform repository:** [https://github.com/senx/warp10-platform](https://github.com/senx/warp10-platform)

- **Warp&nbsp;10 Docker repository:** [https://github.com/senx/warp10-docker](https://github.com/senx/warp10-docker)

- **Maintained by:** [SenX](https://senx.io/)

# What is Warp&nbsp;10™

The Warp&nbsp;10 Platform is designed to collect, store and manipulate sensor data. Sensor data are ingested as sequences of measurements (also called time series). The Warp&nbsp;10 Platform offers the possibility for each measurement to also have spatial metadata specifying the geographic coordinates and/or the elevation of the sensor at the time of the reading. Those augmented measurements form what we call Geo Time Series™ (GTS).
> [warp10.io](https://warp10.io)

<p align="center"><img src="https://warp10.io/assets/img/warp10_bySenx_dark.png" alt="Warp 10 Logo" width="50%"></p>

The easiest way to setup the Warp&nbsp;10™ platform is to use [Docker](https://www.docker.com/). Officials builds are available on [Docker Hub](https://hub.docker.com/r/warp10io/warp10) containing:

- The Warp&nbsp;10™ platform for storing and analyzing Geo&nbsp;Time&nbsp;Series™
- WarpStudio: a web application aiming to allow users to interact with the platform
- Sensision: a service for monitoring Warp&nbsp;10™ platform metrics

# Start a Warp&nbsp;10™ instance

Start your image binding the external ports `8080` for Warp&nbsp;10™ and `8081` for WarpStudio:

```bash
docker run -d -p 8080:8080 -p 8081:8081 warp10io/warp10:tag
```
... where tag is the tag specifying the Warp&nbsp;10™ version you want. See the tab above for relevant tags.

# Mapping volume for persistence

Docker containers are easy to delete. If you delete your container instance, you will lose the Warp&nbsp;10™ storage and configuration. You may want to add a volume mapping to the containers `/data` folder.

```bash
docker run -d -p 8080:8080 -p 8081:8081 --volume=/var/warp10:/data warp10io/warp10:tag
```

In this example, you bind the container internal data folder `/data` to your local folder `/var/warp10`.
You *must* use the same `--volume` option in all your other docker commands on Warp&nbsp;10™ image.

# Working in memory

You can add `-e IN_MEMORY=true` to pop an in-memory Warp&nbsp;10™ instance.
By default, it will retained all last 48 hours.
This is configurable.

```bash
docker run -d -p 8080:8080 -p 8081:8081 -e IN_MEMORY=true warp10io/warp10:tag
```
# Setting JVM heap size

You can use environment variable to set the JVM heap size:
- Initial heap size (Xms) : WARP10_HEAP
- Maximum heap size (Xmx) : WARP10_HEAP_MAX

The default configuration is WARP10_HEAP=1g and WARP10_HEAP_MAX=1g

```bash
docker run -d -p 8080:8080 -p 8081:8081 -e WARP10_HEAP=8g -e WARP10_HEAP_MAX=8g warp10io/warp10:tag
```


# Continuous Integration

A 'Continuous Integration' version is available on DockerHub with the 'ci' suffix.

This version embeds a pair of READ/WRITE tokens named respectively 'readTokenCI', 'writeTokenCI'.

Examples:

```bash
[ 'readTokenCI' '~.*' {} NOW -1 ] FETCH // Retrieve the last point for all GTS
```

```bash
curl -v -H 'X-Warp10-Token: writeTokenCI' --data-binary "1// test{} 42" 'http://127.0.0.1:8080/api/v0/update'
```

# Getting Tokens

The Warp&nbsp;10™ platform is built with a robust security model that allows you to have a tight control of who has the right to write and/or read data. The model is structured around the [concepts](https://www.warp10.io/content/03_Documentation/05_Security/01_Overview) of `data producer`, `data owner` and `application`, and `WRITE` and `READ` tokens.

The 'ci' version embeds a pair of pre-generated READ/WRITE tokens named respectively 'READ', 'WRITE'. These tokens are in the `predictible-tokens-for-ci/ci.tokens` file.

Otherwise, for the purposes of this setup, you need to generate write and read tokens for a test application for a test user that is both the producer and the owner of the data. In order to interact with the user/token/application system, you need an interactive access to Warp&nbsp;10's [TokenGen](https://www.warp10.io/content/03_Documentation/05_Security/03_Token_Management) component.

First, get the container id for your running Warp&nbsp;10™ image:

```bash
$ docker ps
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS                              NAMES
dc6e541e79d8        warp10io/warp10:1.2.9   "/bin/sh -c ${WARP10_"   55 seconds ago      Up 55 seconds       0.0.0.0:8080-8081->8080-8081/tcp   hopeful_einstein
```

Then run `docker exec` to run Worf on that container id:

```bash
docker exec -u warp10 -it dc6e541e79d8 warp10-standalone.sh worf appName ttl(ms)
```

Where `appName` is the chosen application name and `ttl(ms)` the time-of-live of the token in milliseconds.

For example, generate a pair of tokens for an application called `test`, with one year of livespan:

```bash
$ docker exec -u warp10 -it dc6e541e79d8 warp10-standalone.sh worf test 31536000000
default options loaded from file:/opt/warp10/etc/conf.d/.00-secrets.conf.worf
{"read":{"token":"1Uol41cpikTrY5IGUgtwHG4kZ0puh5clethlBuq2Qjs5kWaRhvQOsHKHXsnpH5.lU7GePUIZowFTblA5lkeuDeqFZGgzrmVp1RTWghrA.f5ahLbUVO0S2.","tokenIdent":"ef8cd2a9e3e15fd9","ttl":31536000000,"application":"test","owner":"d7d310cf-254e-4065-87ae-47e83a050ab3","producer":"d7d310cf-254e-4065-87ae-47e83a050ab3"},"write":{"token":"yCY6J7jKJTWgQVrNJpsgPav7ubqiZIlx0jtDibNYO5cJNzq8EziSGOszoXGmFgXFnXbI_Yq3WXg53ry4qXkWU4vkjK9tmE3cWccPbzWvo9c","tokenIdent":"cc3a63e7b7d5ca1b","ttl":31536000000,"application":"test","owner":"d7d310cf-254e-4065-87ae-47e83a050ab3","producer":"d7d310cf-254e-4065-87ae-47e83a050ab3"}}
```

# Testing the container

To test the running container, push a single GTS containing one data in the platform using your WRITE token.

```bash
curl -v -H 'X-Warp10-Token: WRITE_TOKEN' --data-binary "1// test{} 42" 'http://127.0.0.1:8080/api/v0/update'
```

You should receive an HTTP 200.

> When using Docker on Mac OS or Windows, there is no binding between Warp&nbsp;10 API address and the host (docker is running through a Virtual Machine). To reach Warp&nbsp;10 you need to replace 127.0.0.1 by the real IP address of the container. To get it, use a simple `docker-machine ip default>`, the container address is also shown in the Settings/Ports page of your container. If you used the shared volume between the container and the host, you can access to the virtual machine using `docker-machine ssh default>` and inspect the repertory `/var/warp10`. Don't hesitate to check on [docker-machine documentation](https://docs.docker.com/machine/).

Get this data using your READ tokens.

```bash
curl -v --data-binary "[ 'READ_TOKEN' 'test' {} NOW -1 ] FETCH" 'http://127.0.0.1:8080/api/v0/exec'
```

You should receive a HTTP 200 OK with your datapoint in JSON format.

A full [getting started](https://www.warp10.io/content/02_Getting_started) is available to guide your first steps into Warp&nbsp;10™.

# Using WarpStudio
<p align="center"><img src="https://warp10.io/assets/img/warpStudio_dark.png" alt="WarpStudio Logo" width="50%"></p>

[Warp&nbsp;10's WarpStudio](http://studio.senx.io/) is a web application aiming to allow users to interact with the platform in an user-friendly way, offering an alternative to command-line interaction.

> A standalone version of WarpStudio is packaged in the Docker image you have just installed, listening on the port 8081. In a Linux system (with binding between Warp&nbsp;10 API address and the host) you can access WarpStudio at `127.0.0.1:8081`. In Mac OS or Windows, there is no binding between Warp&nbsp;10 API address and the host, you need to replace 127.0.0.1 by the real IP address of the container as explained in the precedent section.

# Build the image

If you want to build your own Warp&nbsp;10 image, clone the Warp&nbsp;10™ docker repository:

```bash
git clone https://github.com/senx/warp10-docker.git
```

Execute `docker build` inside your local copy:

```bash
cd warp10-docker
docker build -t myrepo/warp10:x.y.z .
```

In this example you bind the container internal data folder, `/data` to your local folder `/var/warp10`.

You *must* use the same `--volume` option in all your other docker commands on Warp&nbsp;10™ image.

# For Windows users

First, you have to install [Docker](https://docs.docker.com/docker-for-windows/install/#start-docker-for-windows) and optionally [DockStation](https://dockstation.io/).


```bash
docker run --volume=c:\\warp10:/data -p 8080:8080 -p 8081:8081 -d -i warp10io/warp10:tag
```
