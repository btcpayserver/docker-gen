# Use manifest image which support all architecture
FROM debian:stretch-slim as builder
LABEL maintainer="Jason Wilder <mail@jasonwilder.com>"

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates wget

ENV VERSION 0.7.4
ENV DOWNLOAD_URL https://github.com/jwilder/docker-gen/releases/download/$VERSION/docker-gen-linux-armhf-$VERSION.tar.gz
ENV BIN_SHA256 23d825e99dad9ffd48112877c5afbbea6823807d8beefdfbbc0710b9c5e76975

RUN mkdir /tmp/bin && \
    wget -qO docker-gen.tar.gz $DOWNLOAD_URL && \
    echo "$BIN_SHA256 docker-gen.tar.gz" | sha256sum -c - && \
    tar -xzvf docker-gen.tar.gz -C /tmp/bin

# Making sure the builder build an arm image despite being x64
FROM arm32v7/debian:stretch-slim

COPY --from=builder "/tmp/bin" /usr/local/bin

ENV VERSION 0.7.4
ENV DOCKER_HOST unix:///tmp/docker.sock

ENTRYPOINT ["/usr/local/bin/docker-gen"]
