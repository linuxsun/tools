

### build
```
    #docker build --build-arg WORKDIR_DK="/etc/coredns" --build-arg ETCD_ADDR_DK="http://some-etcd:2379" -t coredns:v1.1.3 .
    docker build --build-arg WORKDIR_DK="/etc/coredns" --build-arg ETCD_ADDR_DK="http://some-etcd:2379" -t harbor.dev.com/demo/coredns:v1.1.3 .
                                                                                        |    ^   |
                                                                                        | (Here) |
```


### run

  1. start etcd
```
    docker pull elcolio/etcd
    docker run -d -p 2379:2379 -p 2380:2380 -p 4001:4001 -p 7001:7001 \
    -v /data/backup/dir:/data --name some-etcd elcolio/etcd:latest
                                    |    ^    |
                                    |  (Here) |        

    see: https://hub.docker.com/r/elcolio/etcd/
```

  2. start coredns
```
    docker run -itd -p 0.0.0.0:53:53/udp -p 0.0.0.0:53:53 --link some-etcd:some-etcd --name coredns coredns:v1.1.3
                                                                |         ^         |
                                                                |       (Here)      |
    see: https://github.com/coreos/etcd
```

### docker push images
```
    docker login harbor.dev.com
    Username: 
    Password:
    docker push harbor.dev.com/demo/coredns:v1.1.3
```

###

https://github.com/linuxsun/tools.git
