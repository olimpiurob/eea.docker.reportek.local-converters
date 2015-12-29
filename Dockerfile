FROM eeacms/centos:7s
MAINTAINER "Olimpiu Rob" <olimpiu.rob@eaudeweb.ro>

ENV PYTHON python
ENV CONFIG base.cfg
ENV SETUPTOOLS 7.0
ENV ZCBUILDOUT 2.2.1
ENV LC_HOME /opt/local_converters

RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "/tmp/get-pip.py" && \
    python /tmp/get-pip.py && \
    pip install scrubber && \
    python3.4 /tmp/get-pip.py && \
    pip3 install chaperone

COPY src/docker-setup.sh           /docker-setup.sh
COPY src/configure.py              /configure.py
COPY src/versions.cfg              $LC_HOME/
COPY src/sources.cfg               $LC_HOME/
COPY src/base.cfg                  $LC_HOME/
COPY src/bootstrap.py              $LC_HOME/
COPY src/converters.tpl            $LC_HOME/
COPY src/chaperone.conf            /etc/chaperone.d/chaperone.conf

WORKDIR $LC_HOME

RUN $PYTHON bootstrap.py -v $ZCBUILDOUT --setuptools-version=$SETUPTOOLS -c $CONFIG && \
    ./bin/buildout -c $CONFIG && \
    mkdir -p $LC_HOME/var && \
    groupadd -g 500 zope-www && \
    useradd  -g 500 -u 500 -m -s /bin/bash zope-www && \
    chown -R 500:500 $LC_HOME

VOLUME $LC_HOME/var/

USER zope-www

ENTRYPOINT ["/usr/bin/chaperone"]
CMD ["--user", "zope-www"]
