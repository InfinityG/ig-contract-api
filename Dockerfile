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
RUN git clone git@github.com:InfinityG/ig-gems.git /home/ig-gems
RUN \
  cd /home/ig-gems/ig-crypto-utils && \
  gem build /home/ig-gems/ig-crypto-utils/ig-crypto-utils.gemspec && \
  gem install /home/ig-gems/ig-crypto-utils/ig-crypto-utils-0.0.1.gem
RUN \
    cd /home/ig-gems/ig-identity-rp-validator && \
    gem build /home/ig-gems/ig-identity-rp-validator/ig-identity-rp-validator.gemspec && \
    gem install /home/ig-gems/ig-identity-rp-validator/ig-identity-rp-validator-0.0.1.gem

RUN git clone git@github.com:InfinityG/ig-contract-api.git /home/ig-contract-api
RUN \
  cd /home/ig-contract-api && \
  bundler install --without test development

WORKDIR /home/ig-contract-api

EXPOSE 9000

CMD rackup

# To build: sudo docker build -t infinityg/ig-contract-api:v1 .
# To run: sudo docker run -it --rm infinityg/ig-contract-api:v1
#   - with port: -p 9000:9000
# Inspect: sudo docker inspect [container_id]
# Delete all containers: sudo docker rm $(docker ps -a -q)
# Delete all images: sudo docker rmi $(docker images -q)
# Connect to running container: sudo docker exec -it [container_id] bash