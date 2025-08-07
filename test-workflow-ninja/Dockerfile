FROM golang:1.20-alpine as builder

WORKDIR /go

RUN git clone https://github.com/golang/go.git .

RUN cd src && ./all.bash

FROM alpine:latest

RUN apk add --no-cache bash

WORKDIR /root/
COPY --from=builder /go/bin/* /usr/local/bin/

ENV GOPATH=/go
ENV GOROOT=/usr/local/go
ENV PATH=$GOROOT/bin:$GOPATH/bin:$PATH

CMD ["go", "version"]
