FROM amazoncorretto:8 AS build

ARG calabash_version=1.2.1-99

USER root
ENV HOME /root
WORKDIR $HOME

RUN yum install -y unzip

ADD https://github.com/ndw/xmlcalabash1/releases/download/$calabash_version/xmlcalabash-$calabash_version.zip ./xmlcalabash.zip

RUN unzip xmlcalabash.zip

COPY calabash.sh /usr/local/bin/

COPY gedcom.xpl ./
COPY lib ./lib

ENTRYPOINT [ "/usr/local/bin/calabash.sh" ]
