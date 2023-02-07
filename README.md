# Warp&nbsp;10 Docker image

<p align="center"><img src="https://warp10.io/assets/img/warp10_bySenx_dark.png" alt="Warp 10 Logo" width="50%"></p>

## Quick reference

- **Where to get help:**
  - Website: https://warp10.io
  - Warp&nbsp;10 community slack: https://lounge.warp10.io/
  - Stack Overflow: https://stackoverflow.com/questions/tagged/warp10

- **Warp&nbsp;10 Platform repository:** [https://github.com/senx/warp10-platform](https://github.com/senx/warp10-platform)

- **Warp&nbsp;10 Docker repository:** [https://github.com/senx/warp10-docker](https://github.com/senx/warp10-docker)

- **Maintained by:** [SenX](https://senx.io/)

## What is Warp&nbsp;10

<p align="center"><a href="https://youtu.be/-5dAB7-dHaQ"><img src="https://warp10.io/assets/img/thumbnail_warp10_video.jpg" alt="Warp 10 simplifies sensor data management and analytics." width="50%"></a></p>

The Warp&nbsp;10 Platform is designed to collect, store and manipulate sensor data. Sensor data are ingested as sequences of measurements (also called time series). The Warp&nbsp;10 Platform offers the possibility for each measurement to also have spatial metadata specifying the geographic coordinates and/or the elevation of the sensor at the time of the reading. Those augmented measurements form what we call Geo Time Series (GTS).

The easiest way to set up the Warp&nbsp;10 platform is to use [Docker](https://www.docker.com/). Officials builds are available on [Docker Hub](https://hub.docker.com/r/warp10io/warp10) containing:

- The Warp&nbsp;10 platform for storing and analyzing Geo&nbsp;Time&nbsp;Series
- WarpStudio: a web application aiming to allow users to interact with the platform
- Sensision: a service for monitoring Warp&nbsp;10 platform metrics

## Start a Warp&nbsp;10 instance

Start your image binding the external ports `8080` for Warp&nbsp;10 and `8081` for WarpStudio:

```bash
docker run -d -p 8080:8080 -p 8081:8081 warp10io/warp10:tag
```
... where tag is the tag specifying the Warp&nbsp;10 version you want.

## Mapping volume for persistence

Docker containers are easy to delete. If you delete your container instance, you will lose the Warp&nbsp;10 storage and configuration. You may want to add a volume mapping to the containers `/data` folder.

```bash
docker run -d -p 8080:8080 -p 8081:8081 --volume=mydata:/data warp10io/warp10:tag
```

In this example, the docker volume `mydata` is mounted in the container internal data folder `/data`. The volume will be created if it does not exist.
Prefer docker volumes to bind mounts.

You *must* use the same `--volume` option in all your other docker commands on Warp&nbsp;10 image.

## Working in memory

You can add `-e IN_MEMORY=true` to pop an in-memory Warp&nbsp;10 instance.
By default, it will retain all last 48 hours.
This is configurable.

```bash
docker run -d -p 8080:8080 -p 8081:8081 -e IN_MEMORY=true warp10io/warp10:tag
```
## Disable Sensision

By default, Sensision collects metrics about the instance usage (ie: number of GTS, number of function calls, …) and store them in your Warp&nbsp;10 instance. This allows you to monitor usage.

You can add `-e NO_SENSISION=true` to disable this behavior.

```bash
docker run -d -p 8080:8080 -p 8081:8081 -e NO_SENSISION=true warp10io/warp10:tag
```

## Setting JVM heap size

You can use environment variable to set the JVM heap size:
- Initial heap size (Xms) : WARP10_HEAP
- Maximum heap size (Xmx) : WARP10_HEAP_MAX

The default configuration is WARP10_HEAP=1g and WARP10_HEAP_MAX=1g

```bash
docker run -d -p 8080:8080 -p 8081:8081 -e WARP10_HEAP=8g -e WARP10_HEAP_MAX=8g warp10io/warp10:tag
```


## Continuous Integration

A 'Continuous Integration' version is available on Docker Hub with the `ci` suffix.

This version embeds a pair of READ/WRITE tokens named respectively `readTokenCI`, `writeTokenCI`.

Examples:

```bash
curl -v -H 'X-Warp10-Token: writeTokenCI' --data-binary "1// test{} 42" 'http://127.0.0.1:8080/api/v0/update'
```

```bash
[ 'readTokenCI' '~.*' {} NOW -1 ] FETCH // Retrieve the last point for all GTS
```

## Getting Tokens

The Warp&nbsp;10 platform is built with a robust security model that allows you to have a tight control of who has the right to write and/or read data. The model is structured around the [concepts](https://www.warp10.io/content/03_Documentation/05_Security/01_Overview) of `data producer`, `data owner` and `application`, and `WRITE` and `READ` tokens.

The `ci` version embeds a pair of pre-generated READ/WRITE tokens named respectively `readTokenCI` and `writeTokenCI`. These tokens are in the `predictible-tokens-for-ci/ci.tokens` file.

Otherwise, for the purposes of this setup, you need to generate write and read tokens for a test application for a test user that is both the producer and the owner of the data. In order to interact with the user/token/application system, you need interactive access to Warp&nbsp;10's [TokenGen](https://www.warp10.io/content/03_Documentation/05_Security/03_Token_Management) component.

Create an `envelope` file and, adapt it to your needs. Here is an example:
```warpscript
'myapp' 'applicationName' STORE
NOW 1 ADDYEARS 'expiryDate' STORE
UUID 'ownerAndProducer' STORE

{
  'id' 'TokenRead'
  'type' 'READ'
  'application' $applicationName
  'owner'  $ownerAndProducer
  'issuance' NOW
  'expiry' $expiryDate
  'labels' { }
  'attributes' { }
  'owners' [ $ownerAndProducer ]
  'producers' [ $ownerAndProducer ]
  'applications' [ $applicationName ]
}
TOKENGEN

{
  'id' 'TokenWrite'
  'type' 'WRITE'
  'application' $applicationName
  'owner'  $ownerAndProducer
  'producer' $ownerAndProducer
  'issuance' NOW
  'expiry' $expiryDate
  'labels' { }
  'attributes' { }
}
TOKENGEN
```

```bash
docker exec -i <container_id> warp10-standalone.sh tokengen - < envelope.mc2
```

```bash
docker exec -i 77426631869b warp10-standalone.sh tokengen - < envelope.mc2 | jq
2023-01-23T13:54:30,594 main WARN  script.WarpFleetMacroRepository - No validator macro, default macro will reject all URLs.
[
  {
    "ident": "60c9181d536a029e",
    "id": "TokenWrite",
    "token": "H.dqA7BMoH0uVfrHK7QRlKgjQLXWGfMC0jTJZqImmeoaS15rp5LkyxnOXhp2ni3gmAtEyokdU88efOKHc_B2frXjlhUH3HBZRZv6bCHYLsPUJGlgvO2hQV"
  },
  {
    "ident": "b0d69f77c2596974",
    "id": "TokenRead",
    "token": "WZ2CmZtSG9wfcdHEb2r2ePHkZGF7Cd8W1PzWQ5o_1azarQS3KdO9q2VxFMQ.3mk1o1OHxdKfXERQWcNlJCgRWs0exZUZdAwSqw0rp.KD1sNDJSbkXDS0_wPivLc.yi_Qdsm5kgz1fp0rgJIWylL3_."
  }
]
```

## Testing the container

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

You should receive an HTTP 200 OK with your data point in JSON format.

A full [getting started](https://www.warp10.io/content/02_Getting_started) is available to guide your first steps into Warp&nbsp;10.

## Using WarpStudio
<p align="center"><img src="https://warp10.io/assets/img/warpStudio_dark.png" alt="WarpStudio Logo" width="50%"></p>

[Warp&nbsp;10's WarpStudio](http://studio.senx.io/) is a web application aiming to allow users to interact with the platform in a user-friendly way, offering an alternative to command-line interaction.

> A standalone version of WarpStudio is packaged in the Docker image you have just installed, listening on the port 8081. In a Linux system (with binding between Warp&nbsp;10 API address and the host) you can access WarpStudio at `127.0.0.1:8081`. In macOS or Windows, there is no binding between Warp&nbsp;10 API address and the host, you need to replace 127.0.0.1 by the real IP address of the container as explained in the precedent section.

## Configure Warp 10
They are many ways to configure Warp 10 in docker. Each of the following methods allows you to add or replace existing configuration.

- Using extra configuration file:

Use the `/config.extra` folder to add your additional configuration file, you can add multiple files.
```
docker run -d -p 8080:8080 -p 8081:8081 -v 99-custom.conf:/config.extra/99-custom.conf warp10io/warp10:tag
```
- Using environment variables:
```bash
docker run -d -p 8080:8080 -p 8081:8081 -e warpscript.maxops=100000 -e warpscript.maxfetch=1000000 warp10io/warp10:tag
 ```
- Using environment file:
 ```bash
docker run -d -p 8080:8080 -p 8081:8081 --env-file=./myconf.env warp10io/warp10:tag
 ```

You can mix all of these methods, here is an example with docker-compose:
```
services:
  warp10:
    image: warp10io/warp10:tag
    volumes:
      - warp10_data:/data
      - /var/warp10/99-custom.conf:/config.extra/99-custom.conf
    ports:
      - '8080:8080'
      - '8081:8081'
    environment:
      - warpscript.maxops=100000
      - warpscript.maxfetch=1000000
    env_file: custom.env
volumes:
  warp10_data:
```

## Build the image

If you want to build your own Warp&nbsp;10 image, clone the Warp&nbsp;10 docker repository:

```bash
git clone https://github.com/senx/warp10-docker.git
```

Execute `docker build` inside your local copy:

```bash
cd warp10-docker
docker build -t myrepo/warp10:x.y.z -f ubuntu/Dockerfile .
```

In this example you bind the container internal data folder, `/data` to your local folder `/var/warp10`.

You *must* use the same `--volume` option in all your other docker commands on Warp&nbsp;10 image.

## For Windows users

First, you have to install [Docker](https://docs.docker.com/docker-for-windows/install/#start-docker-for-windows) and optionally [DockStation](https://dockstation.io/).


```bash
docker run --volume=c:\\warp10:/data -p 8080:8080 -p 8081:8081 -d -i warp10io/warp10:tag
```
