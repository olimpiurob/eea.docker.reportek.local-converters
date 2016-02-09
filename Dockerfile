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
    pip3 install chaperone && \
    rpm -ivh "http://pkgs.repoforge.org/unrar/unrar-5.0.3-1.el7.rf.x86_64.rpm" && \
    rpm -ivh "http://pkgs.repoforge.org/wv/wv-1.2.4-1.el6.rf.x86_64.rpm" && \
    rpm -ivh "ftp://rpmfind.net/linux/sourceforge/x/xo/xoonips/[extras]%20xlhtml/xlhtml-0.5.1.p1/el6/xlhtml-0.5.1.p1-1.el6.x86_64.rpm"


COPY src/docker-setup.sh           /docker-setup.sh
COPY src/configure.py              /configure.py
COPY src/versions.cfg              $LC_HOME/
COPY src/sources.cfg               $LC_HOME/
COPY src/base.cfg                  $LC_HOME/
COPY src/converters.cfg            $LC_HOME/
COPY src/bootstrap.py              $LC_HOME/
COPY src/converters.tpl            $LC_HOME/
COPY src/chaperone.conf            /etc/chaperone.d/chaperone.conf

RUN groupadd -g 500 zope-www && \
    useradd  -g 500 -u 500 -m -s /bin/bash zope-www

WORKDIR /var/local
RUN curl "http://download.osgeo.org/geos/geos-3.3.8.tar.bz2" -o "/var/local/geos-3.3.8.tar.bz2" && \
    tar -jxvf geos-3.3.8.tar.bz2 && rm geos-3.3.8.tar.bz2 && \
    cd geos-3.3.8 && \
    CFLAGS="-m64" CPPFLAGS="-m64" CXXFLAGS="-m64" LDFLAGS="-m64" FFLAGS="-m64" LDFLAGS="-L/usr/lib64/" ./configure && \
    make && make check && make install clean && cd /var/local && rm -rf geos-3.3.8

RUN curl "http://download.osgeo.org/proj/proj-4.8.0.tar.gz" -o "/var/local/proj-4.8.0.tar.gz" && \
    cd /var/local && tar -zxvf proj-4.8.0.tar.gz && rm proj-4.8.0.tar.gz && cd proj-4.8.0 && \
    ./configure && make && make install clean && cd /var/local && rm -rf proj-4.8.0

RUN curl "http://www.gaia-gis.it/gaia-sins/freexl-1.0.2.tar.gz" -o "/var/local/freexl-1.0.2.tar.gz" && \
    cd /var/local && tar -zxvf freexl-1.0.2.tar.gz && rm freexl-1.0.2.tar.gz && cd freexl-1.0.2 && \
    ./configure && make && make install clean && cd /var/local && rm -rf freexl-1.0.2

RUN curl "http://www.gaia-gis.it/gaia-sins/libspatialite-sources/libspatialite-4.1.0.tar.gz" -o "/var/local/libspatialite-4.1.0.tar.gz" && \
    cd /var/local && tar -zxvf libspatialite-4.1.0.tar.gz && rm libspatialite-4.1.0.tar.gz && cd libspatialite-4.1.0 && \
    ./configure && make && make install clean && cd /var/local && rm -rf libspatialite-4.1.0

RUN curl "http://www.gaia-gis.it/gaia-sins/readosm-1.0.0e.tar.gz" -o "/var/local/readosm-1.0.0e.tar.gz" && \
    cd /var/local && tar -zxvf readosm-1.0.0e.tar.gz && rm readosm-1.0.0e.tar.gz && cd readosm-1.0.0e && \
    ./configure && make && make install clean && cd /var/local && rm -rf readosm-1.0.0e

RUN curl "http://www.gaia-gis.it/gaia-sins/spatialite-tools-sources/spatialite-tools-4.1.0.tar.gz" -o "/var/local/spatialite-tools-4.1.0.tar.gz" && \
    cd /var/local && tar -zxvf spatialite-tools-4.1.0.tar.gz && rm spatialite-tools-4.1.0.tar.gz && cd spatialite-tools-4.1.0 && \
    PKG_CONFIG_PATH="/usr/local/lib/pkgconfig" ./configure && make && make install clean && \
    cd /var/local && rm -rf spatialite-tools-4.1.0

RUN svn co "https://svn.eionet.europa.eu/repositories/Reportnet/Dataflows/CDDA/2013/cdda-spatialite/" && \
    chown -R 500:500 /var/local/cdda-spatialite

WORKDIR $LC_HOME

RUN $PYTHON bootstrap.py -v $ZCBUILDOUT --setuptools-version=$SETUPTOOLS -c $CONFIG && \
    ./bin/buildout -c $CONFIG && \
    mkdir -p $LC_HOME/var && \
    chown -R 500:500 $LC_HOME

VOLUME $LC_HOME/var/

USER zope-www

ENTRYPOINT ["/usr/bin/chaperone"]
CMD ["--user", "zope-www"]
