FROM almalinux:8.9

ENV PYTHON python
ENV CONFIG base.cfg
ENV SETUPTOOLS 44.1.1
ENV LC_HOME /opt/local_converters

ADD src/install-dependencies.sh /bin/install-dependencies
ADD src/*.yum /etc/yum/

COPY src/docker-setup.sh           \
     src/configure.py              /
COPY src/versions.cfg              \
     src/sources.cfg               \
     src/base.cfg                  \
     src/converters.cfg            \
     src/converters.tpl            $LC_HOME/

WORKDIR /var/local
RUN yum update -y && yum install -y epel-release && yum install -y python27 && \
    alternatives --set python /usr/bin/python2 && \
    dnf -y update && dnf install -y epel-release && \
    dnf config-manager --set-enabled powertools && \
    dnf install -y freexl graphviz-devel gdal gdal-libs ImageMagick \
     ImageMagick-devel python2-devel libtiff-devel libcurl-devel geos geos-devel \
     proj libspatialite-devel readosm proj-devel && \
    /bin/install-dependencies /etc/yum/ && \
    \
    groupadd -g 500 zope-www && \
    useradd  -g 500 -u 500 -m -s /bin/bash zope-www && \
    pip2 install --upgrade pip setuptools && \
    pip2 install zc.buildout && \
    curl -L "http://pkgs.fedoraproject.org/repo/extras/xlhtml/xlhtml-0.5.tgz/2ff805c5384bdde9675cb136f54df32e/xlhtml-0.5.tgz" -o "/var/local/xlhtml-0.5.tgz" && \
    cd /var/local && tar -zxvf xlhtml-0.5.tgz && rm xlhtml-0.5.tgz && cd xlhtml-0.5 && \
    curl -L "http://savannah.gnu.org/cgi-bin/viewcvs/*checkout*/config/config/config.sub" -o "config.sub" && \
    curl -L "http://savannah.gnu.org/cgi-bin/viewcvs/*checkout*/config/config/config.guess" -o "config.guess" && \
    ./configure && make && make install clean && cd /var/local && rm -rf xlhtml-05

WORKDIR $LC_HOME

RUN buildout -c $CONFIG && \
    pip2 install -r $LC_HOME/src/reportek.converters/requirements.txt && \
    mkdir -p $LC_HOME/var && \
    chown -R 500:500 $LC_HOME && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /var/cache/dnf

HEALTHCHECK --interval=3m --timeout=5s --start-period=1m \
  CMD nc -z -w5 127.0.0.1 5000 || exit 1

VOLUME $LC_HOME/var/

ENTRYPOINT ["/docker-setup.sh"]
CMD []
