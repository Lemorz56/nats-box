FROM golang:1.13.4-alpine3.10 AS builder

LABEL maintainer "Derek Collison <derek@nats.io>"
LABEL maintainer "Waldemar Quevedo <wally@nats.io>"
LABEL maintainer "Jaime Piña <jaime@nats.io>"

WORKDIR $GOPATH/src/github.com/nats-io/

RUN apk add -U --no-cache git binutils

RUN go get github.com/nats-io/nats-top

# Force the go compiler to use modules
# ENV GO111MODULE=on

RUN go get github.com/nats-io/nsc
RUN go get github.com/nats-io/stan.go/examples/stan-pub
RUN go get github.com/nats-io/stan.go/examples/stan-sub

# Simple tools
COPY . .
RUN go install
RUN strip /go/bin/*

FROM alpine:3.10

RUN apk add -U --no-cache ca-certificates figlet

COPY --from=builder /go/bin/* /usr/local/bin/
RUN cd /usr/local/bin/ && ln -s nats-util nats-pub && ln -s nats-util nats-sub && ln -s nats-util nats-req

WORKDIR /root

USER root

ENV NKEYS_PATH /nsc
ENV NSC_HOME /nsc/accounts
ENV NATS_CONFIG_HOME /nsc/config

ENTRYPOINT ["/bin/sh"]
