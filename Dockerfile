FROM eeacms/centos:7s
MAINTAINER "Olimpiu Rob" <olimpiu.rob@eaudeweb.ro>

ENV PYTHON python
ENV CONFIG base.cfg
ENV SETUPTOOLS 28.6.0
ENV ZCBUILDOUT 2.5.3
ENV LC_HOME /opt/local_converters

RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "/tmp/get-pip.py" && \
    python /tmp/get-pip.py && \
    pip2 install scrubber path.py==9.1 dbf==0.96.8 enum34==1.1.6 Jinja2==2.9.6 && \
    python3.4 /tmp/get-pip.py && \
    pip3 install chaperone && \
    rpm -ivh "ftp://fr2.rpmfind.net/linux/dag/redhat/el7/en/x86_64/dag/RPMS/unrar-5.0.3-1.el7.rf.x86_64.rpm" && \
    rpm -ivh "ftp://fr2.rpmfind.net/linux/epel/6/x86_64/wv-1.2.7-2.el6.x86_64.rpm"

COPY src/docker-setup.sh           \
     src/configure.py              /
COPY src/versions.cfg              \
     src/sources.cfg               \
     src/base.cfg                  \
     src/converters.cfg            \
     src/bootstrap.py              \
     src/converters.tpl            $LC_HOME/
COPY src/chaperone.conf            /etc/chaperone.d/chaperone.conf

RUN groupadd -g 500 zope-www && \
    useradd  -g 500 -u 500 -m -s /bin/bash zope-www

WORKDIR /var/local
RUN curl -L "http://pkgs.fedoraproject.org/repo/extras/xlhtml/xlhtml-0.5.tgz/2ff805c5384bdde9675cb136f54df32e/xlhtml-0.5.tgz" -o "/var/local/xlhtml-0.5.tgz" && \
    cd /var/local && tar -zxvf xlhtml-0.5.tgz && rm xlhtml-0.5.tgz && cd xlhtml-0.5 && \
    curl -L "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD" -o "config.sub" && \
    ./configure && make && make install clean && cd /var/local && rm -rf xlhtml-05 && \

    curl "http://download.osgeo.org/geos/geos-3.3.8.tar.bz2" -o "/var/local/geos-3.3.8.tar.bz2" && \
    tar -jxvf geos-3.3.8.tar.bz2 && rm geos-3.3.8.tar.bz2 && \
    cd geos-3.3.8 && \
    CFLAGS="-m64" CPPFLAGS="-m64" CXXFLAGS="-m64" LDFLAGS="-m64" FFLAGS="-m64" LDFLAGS="-L/usr/lib64/" ./configure && \
    make && make check && make install clean && cd /var/local && rm -rf geos-3.3.8 && \

    curl "http://download.osgeo.org/proj/proj-4.8.0.tar.gz" -o "/var/local/proj-4.8.0.tar.gz" && \
    cd /var/local && tar -zxvf proj-4.8.0.tar.gz && rm proj-4.8.0.tar.gz && cd proj-4.8.0 && \
    ./configure && make && make install clean && cd /var/local && rm -rf proj-4.8.0 && \

    curl "http://www.gaia-gis.it/gaia-sins/freexl-1.0.2.tar.gz" -o "/var/local/freexl-1.0.2.tar.gz" && \
    cd /var/local && tar -zxvf freexl-1.0.2.tar.gz && rm freexl-1.0.2.tar.gz && cd freexl-1.0.2 && \
    ./configure && make && make install clean && cd /var/local && rm -rf freexl-1.0.2 && \

    curl "http://www.gaia-gis.it/gaia-sins/libspatialite-sources/libspatialite-4.1.0.tar.gz" -o "/var/local/libspatialite-4.1.0.tar.gz" && \
    cd /var/local && tar -zxvf libspatialite-4.1.0.tar.gz && rm libspatialite-4.1.0.tar.gz && cd libspatialite-4.1.0 && \
    ./configure && make && make install clean && cd /var/local && rm -rf libspatialite-4.1.0 && \

    curl "http://www.gaia-gis.it/gaia-sins/readosm-1.0.0e.tar.gz" -o "/var/local/readosm-1.0.0e.tar.gz" && \
    cd /var/local && tar -zxvf readosm-1.0.0e.tar.gz && rm readosm-1.0.0e.tar.gz && cd readosm-1.0.0e && \
    ./configure && make && make install clean && cd /var/local && rm -rf readosm-1.0.0e && \

    curl "http://www.gaia-gis.it/gaia-sins/spatialite-tools-sources/spatialite-tools-4.1.0.tar.gz" -o "/var/local/spatialite-tools-4.1.0.tar.gz" && \
    cd /var/local && tar -zxvf spatialite-tools-4.1.0.tar.gz && rm spatialite-tools-4.1.0.tar.gz && cd spatialite-tools-4.1.0 && \
    PKG_CONFIG_PATH="/usr/local/lib/pkgconfig" ./configure && make && make install clean && \
    cd /var/local && rm -rf spatialite-tools-4.1.0 && \

    svn co "https://svn.eionet.europa.eu/repositories/Reportnet/Dataflows/CDDA/2013/cdda-spatialite/" && \
    chown -R 500:500 /var/local/cdda-spatialite && \

    curl "https://ayera.dl.sourceforge.net/project/gawkextlib/xgawk/xgawk-3.1.6-20080101/xgawk-3.1.6-20080101.tar.gz" -o "/var/local/xgawk-3.1.6-20080101.tar.gz" && \
    cd /var/local && tar -zxvf xgawk-3.1.6-20080101.tar.gz && rm -f xgawk-3.1.6-20080101.tar.gz && cd xgawk-3.1.6-20080101 && \
    ./configure --prefix=/usr && make && sed -i 's/\$\$p/\.libs\/\$\$p/g' extension/Makefile && make install clean && \
    cd /var/local && rm -rf xgawk-3.1.6-2008010

WORKDIR $LC_HOME

RUN $PYTHON bootstrap.py -v $ZCBUILDOUT --setuptools-version=$SETUPTOOLS -c $CONFIG && \
    ./bin/buildout -c $CONFIG && \
    mkdir -p $LC_HOME/var && \
    chown -R 500:500 $LC_HOME

VOLUME $LC_HOME/var/

ENTRYPOINT ["/usr/bin/chaperone"]
CMD ["--user", "zope-www"]
