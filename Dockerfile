FROM almalinux:9.3

ENV PYTHON python
ENV CONFIG base.cfg
ENV LC_HOME /opt/local_converters

ADD src/install-dependencies.sh /bin/install-dependencies
ADD src/*.yum /etc/yum/

COPY src/docker-setup.sh          \
    src/configure.py             /
COPY src/versions.cfg             \
    src/sources.cfg               \
    src/base.cfg                  \
    src/converters.cfg            \
    src/converters.tpl            $LC_HOME/

WORKDIR /var/local
RUN yum update -y && yum install -y git epel-release && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3 20 && \
    dnf -y update && dnf install -y epel-release && \
    dnf config-manager --set-enabled crb && \
    dnf install -y freexl graphviz-devel gdal gdal-libs ImageMagick \
    ImageMagick-devel python-devel libtiff-devel libcurl-devel geos geos-devel \
    proj libspatialite-devel readosm proj-devel automake && \
    /bin/install-dependencies /etc/yum/ && \
    \
    groupadd -g 500 zope-www && \
    useradd  -g 500 -u 500 -m -s /bin/bash zope-www && \
    yum remove pip setuptools -y && \
    python -m ensurepip --upgrade && python -m pip install -U pip && \
    pip install zc.buildout beautifulsoup4 setuptools && \
    pip install --upgrade setuptools && \
    curl -L "https://anduin.linuxfromscratch.org/BLFS/wv/wv-1.2.9.tar.gz" -o "/var/local/wv-1.2.9.tar.gz" && \
    cd /var/local && tar -zxvf wv-1.2.9.tar.gz && rm wv-1.2.9.tar.gz && cd wv-1.2.9 && \
    curl -L "http://savannah.gnu.org/cgi-bin/viewcvs/*checkout*/config/config/config.sub" -o "config.sub" && \
    curl -L "http://savannah.gnu.org/cgi-bin/viewcvs/*checkout*/config/config/config.guess" -o "config.guess" && \
    ./configure && make && make install clean && cd /var/local && rm -rf wv-1.2.9

WORKDIR $LC_HOME

RUN buildout -c $CONFIG && \
    cd src/scrubber && python setup.py install && \
    pip install -r $LC_HOME/src/reportek.converters/requirements.txt && \
    mkdir -p $LC_HOME/var && \
    chown -R 500:500 $LC_HOME && \
    yum autoremove -y gcc gcc-c++ && \
    yum clean all && \
    dnf clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /var/cache/dnf

HEALTHCHECK --interval=3m --timeout=5s --start-period=1m \
    CMD nc -z -w5 127.0.0.1 5000 || exit 1

VOLUME $LC_HOME/var/

ENTRYPOINT ["/docker-setup.sh"]
CMD []
