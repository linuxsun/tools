FROM alpine:latest
MAINTAINER Miek Gieben <miek@miek.nl> @miekg

ARG WORKDIR_DK
ARG ETCD_ADDR_DK
ENV WORKDIR $WORKDIR_DK
ENV ETCD_ADDR $ETCD_ADDR_DK

RUN apk --update add bind-tools ca-certificates openssl && update-ca-certificates && rm -rf /var/cache/apk/*
WORKDIR $WORKDIR
COPY coredns $WORKDIR
COPY Corefile $WORKDIR
RUN sed -i "s|ETCD_ADDR|$ETCD_ADDR|g" $WORKDIR/Corefile
#COPY corednsd /etc/rc.d/init.d/coredns
EXPOSE 53 53/udp

CMD ["sh","-c","$WORKDIR/coredns -conf $WORKDIR/Corefile"]
