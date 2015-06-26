FROM ubuntu:14.04
MAINTAINER Grant Pidwell <grantpidwell@infinity-g.com>

#### General ####

RUN apt-get update && apt-get install -y curl wget git

#### Install Ruby, Bundler ####

RUN \
  apt-get update && \
  apt-get install -y ruby ruby-dev ruby-bundler && \
  rm -rf /var/lib/apt/lists/*
RUN gem install bundler

#### SSH keys for Github access ####
# Ensure that the /.ssh folder is present in the root context!

RUN mkdir -p /root/.ssh
ADD /.ssh/id_rsa /root/.ssh/id_rsa
RUN chmod 700 /root/.ssh/id_rsa
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
RUN echo "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

#### Clone Github repos ####

RUN mkdir -p home
RUN git clone git@github.com:InfinityG/ig-contract-api.git /home/ig-contract-api
RUN cd /home/ig-contract-api && \
    bundler install --without test development

#### Set up MongoDB ####

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/10gen.list
RUN apt-get update && apt-get install -y mongodb-org
RUN mkdir -p /data/db

####

### Set up static designer ###
### Install NodeJS, npm, Bower, Gulp ###

RUN cd /home/ig-contract-api/designer && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:chris-lea/node.js && \
    apt-get update && apt-get install -y curl wget git nodejs && \
    npm install bower -g && \
    npm install gulp -g && \
    npm install && \
    bower install --allow-root && \
    gulp

### Set up working directory

WORKDIR /home/ig-contract-api

EXPOSE 8002

# CMD rackup
CMD mongod --fork --logpath /var/log/mongodb.log && rackup -E test

# To build: sudo docker build -t infinityg/ig-contract-api:v1 .
# To run: sudo docker run -it --rm infinityg/ig-contract-api:v1
#   - with port: -p 8002:8002
# Inspect: sudo docker inspect [container_id]
# Delete all containers: sudo docker rm $(docker ps -a -q)
# Delete all images: sudo docker rmi $(docker images -q)
# Connect to running container: sudo docker exec -it [container_id] bash
# Attach to running container: sudo docker attach [container_id]
# Detach from running container without stopping process: Ctrl-p Ctrl-q
# Restart Docker service: sudo service docker.io restart