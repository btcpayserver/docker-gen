FROM golang:1.11-alpine3.9 as builder

RUN apk add --no-cache --update git make gcc alpine-sdk 

WORKDIR /go/src/github.com/jwilder/docker-gen
COPY Makefile Makefile
COPY GLOCKFILE GLOCKFILE
RUN make get-deps
COPY . .
RUN TAG=$(git describe --tags) && \
    export LDFLAGS="-X main.buildVersion=${TAG}" && \
     GOOS=linux GOARCH=arm64 go build -ldflags "${LDFLAGS}" -a -tags netgo -installsuffix netgo -o /usr/local/bin/docker-gen ./cmd/docker-gen

FROM arm64v8/alpine:3.9

COPY --from=builder /usr/local/bin/docker-gen /usr/local/bin/docker-gen

ENV VERSION 0.7.5
ENV DOCKER_HOST unix:///tmp/docker.sock

ENTRYPOINT ["/usr/local/bin/docker-gen"]
