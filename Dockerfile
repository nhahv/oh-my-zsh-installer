FROM centos:7
COPY install.sh .
RUN sh install.sh

CMD ["/bin/zsh"]


FROM centos:8
COPY install.sh .
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
RUN sh install.sh

CMD ["/bin/zsh"]


FROM amazonlinux:2
COPY install.sh .
RUN sh install.sh

CMD ["/bin/zsh"]

#DEIAN 9
FROM debian:stretch
RUN apt-get update
COPY install.sh .
RUN sh install.sh
RUN ["/bin/zsh"]

#DEIAN 10
FROM debian:buster
RUN apt-get update
COPY install.sh .
RUN sh install.sh
RUN ["/bin/zsh"]

#DEIAN 11
FROM debian:bullseye
RUN apt-get update
COPY install.sh .
RUN sh install.sh
RUN ["/bin/zsh"]


#UBUNTU 18.04
FROM ubuntu:18.04
RUN apt-get update
COPY install.sh .
RUN sh install.sh
RUN ["/bin/zsh"]

#Ubuntu 20.04
FROM ubuntu:20.04
RUN apt-get update
COPY install.sh .
RUN sh install.sh
RUN ["/bin/zsh"]

#DEIAN 22.04
FROM ubuntu:22.04
RUN apt-get update
COPY install.sh .
RUN sh install.sh
RUN ["/bin/zsh"]

#ALPINE 3.14
FROM alpine:3.14
COPY install.sh .
RUN sh install.sh
RUN ["/bin/zsh"]

#ALPINE 3.15
FROM alpine:3.15
COPY install.sh .
RUN sh install.sh
RUN ["/bin/zsh"]

#ALPINE 3.16
FROM alpine:3.16
COPY install.sh .
RUN sh install.sh
RUN ["/bin/zsh"]

#ALPINE 3.14
FROM alpine:3.14
COPY install.sh .
RUN sh install.sh
RUN ["/bin/zsh"]

#ALPINE 3.15
FROM alpine:3.15
COPY install.sh .
RUN sh install.sh
RUN ["/bin/zsh"]

#ALPINE 3.16
FROM alpine:3.16
COPY install.sh .
RUN sh install.sh
RUN ["/bin/zsh"]