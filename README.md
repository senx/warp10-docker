# Introduction

`Dockerfile` to create a [Docker](https://www.docker.com/) container image for [Warp 10](https://www.warp10.io/).

# Getting started

## Installation

The easiest way to setup the Warp10 platform is to use [Docker](http://docker.io). Automated builds of the Docker Warp10 image will be available on [Dockerhub](https://hub.docker.com/) and is the recommended method of installation. Until then, you can build the image yourself:

Clone this repository

~~~
  git clone https://github.com/cityzendata/warp10-docker.git
~~~

Execute `docker build` inside your local copy

~~~
  cd warp10-docker
  docker build -t warp10/warp10:1.0.5 .
~~~


### Running your Warp10 image

Start Warp 10 platform using:

Start your image binding the external ports 8080 and 8081 in all interfaces to your container.

~~~
  docker run  -p 8080:8080 -p 8081:8081 -d -i warp10/warp10:1.0.5
~~~

Docker containers are easy to delete. If you delete your container instance, you'll lose the Warp10 store and configuration. If you are serious about keeping Warp data persistently, then consider adding a volume mapping to the containers `/data` folder:

~~~
  docker run --volume=/var/warp10:/data -p 8080:8080 -p 8081:8081 -d -i warp10/warp10:1.0.5
~~~

In this example you bind the container internal data folder, `/data` to your local folder `/var/warp10`.

If you use this option you *must* use the same `--volume` option in all your other docker commands on warp10 image.

### Generating Tokens

The Warp 10 platform is built with a robust security model that allows you to have a tight control of who has the right to write and/or read data. The model is structured around the [concepts](http://www.warp10.io//introduction/concepts) of `data producer`, `data owner` and `application`, and `WRITE` and `READ` tokens.  

For the purposes of this setup, you need to generate write and read tokens for a test application for a test user that is both the producer and the owner of the data. In order to interact with the user/token/application system, you need an interactive access to Warp10's [Worf](http://www.warp10.io/tools/worf) component. You get it by executing `worf.sh` on the running container.

First, get the container id for your running Warp 10 image:

~~~
  $ docker ps
  CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                              NAMES
  821b868e20be        warp10/warp10:1.0.5   "/bin/sh -c ${WARP10_"   3 minutes ago       Up 3 minutes        0.0.0.0:8080-8081->8080-8081/tcp   cranky_noyce
~~~

Then run `docker exec` to run Worf console on that container id:

~~~
  docker exec   -t -i 821b868e20be worf.sh
~~~


Inside Worf console, you can use the `encodeToken` command to generate both a `READ` and a `WRITE` token for the default users and application.

![Generating tokens with Worf](http://www.warp10.io/img/getting-started/generating-tokens-with-worf.png)


## Testing the container


To test the running container, push a single GTS containing one data in the platform using your WRITE token.

  ```
  curl -v -H 'X-Warp10-Token: WRITE_TOKEN' --data-binary "1// test{} 42" 'http://127.0.0.1:8080/api/v0/update'
  ```

If everything is OK, you should receive a HTTP 200

> When using Docker on Mac OS or Windows, there is no binding between Warp 10 API address and the host (docker is runned throw a Virtual Machine). To reach Warp10 you need to replace 127.0.0.1 by the real Ip address of the container. To get it, use a simple `docker-machine ip default>`, the container address is also shown in the Settings/Ports page of your container. If you used the shared volume between the container and the host, you can access to the virtual machine using `docker-machine ssh default>` and inspect the repertory `/var/warp10`. Don't hesitate to check on [docker-machine documentation](https://docs.docker.com/machine/).

Get this data using your READ tokens.

```
curl -v  --data-binary "'READ_TOKEN' 'test' {} NOW -1 FETCH" 'http://127.0.0.1:8080/api/v0/exec'
```

If everything is OK, you should receive a HTTP 200 OK with your datapoint in JSON format.


A full [getting started](http://www.warp10.io/howto/getting-started/) is available to guide your first steps into Warp 10.



### Using Quantum

[Warp 10's Quantum](http://www.warp10.io/tools/quantum) is a web application aiming to allow users to interact with the platform in an user-friendly way, offering an alternative to command-line interaction.

> A standalone version of Quantum is packaged in the Docker image you have just installed, listening on the port 8081. In a Linux system (with binding between Warp 10 API address and the host) you can access Quantum at `127.0.0.1:8081`. In Mac OS or Windows, there is no binding between Warp 10 API address and the host, you need to replace 127.0.0.1 by the real Ip address of the container as explained in the precedent section.

![Quantum](http://www.warp10.io/img/getting-started/quantum-warpscript.png)
