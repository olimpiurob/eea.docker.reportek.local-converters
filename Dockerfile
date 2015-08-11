FROM eeacms/centos:7
MAINTAINER "Olimpiu Rob" <olimpiu.rob@eaudeweb.ro>

ENV PYTHON python
ENV CONFIG base.cfg
ENV SETUPTOOLS 7.0
ENV ZCBUILDOUT 2.2.1
ENV LC_HOME /opt/local_converters

COPY src/start.sh           /usr/bin/start
COPY src/versions.cfg       $LC_HOME/
COPY src/sources.cfg        $LC_HOME/
COPY src/base.cfg           $LC_HOME/
COPY src/bootstrap.py       $LC_HOME/
COPY src/install.sh         $LC_HOME/

RUN mkdir -p $LC_HOME/var && \
    groupadd -g 500 zope-www && \
    useradd  -g 500 -u 500 -m -s /bin/bash zope-www && \
    chown -R 500:500 $LC_HOME

WORKDIR $LC_HOME
RUN ./install.sh
VOLUME $LC_HOME/var/

CMD ["start"]
