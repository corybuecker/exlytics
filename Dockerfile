FROM golang:rc-alpine
COPY . $GOPATH/src/exlytics
WORKDIR $GOPATH/src/exlytics
RUN go mod download && go build

FROM alpine:3.13
RUN addgroup -g 5000 exlytics && \
  adduser -u 5000 -G exlytics -s /bin/sh -D exlytics
COPY --from=0 /go/src/exlytics/exlytics /home/exlytics/exlytics
RUN chown -R exlytics:exlytics /home/exlytics

USER exlytics
WORKDIR /home/exlytics

ENTRYPOINT ["/home/exlytics/exlytics"]