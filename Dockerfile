# vim:set ft=dockerfile:
FROM centos:8

# Update system
RUN dnf -y install epel-release && \
    dnf -y upgrade

# Install some basic dependencies
RUN dnf -y install bind-utils \
    bc \
    boost \
    expect \
    glibc-langpack-en \
    jemalloc \
    jq \
    less \
    libaio \
    monit \
    nano \
    net-tools \
    openssl \
    perl \
    perl-DBI \
    python3 \
    python3-cherrypy \
    python3-requests \
    python3-lxml \
    python3-routes \
    rsyslog \
    snappy \
    sudo \
    tcl \
    vim \
    wget

# Default env variables
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV TINI_VERSION=v0.18.0

# Add MariaDB Repo
#RUN wget -O /tmp/mariadb_repo_setup https://downloads.mariadb.com/MariaDB/mariadb_repo_setup && \
#    chmod +x /tmp/mariadb_repo_setup && \
#    ./tmp/mariadb_repo_setup --mariadb-server-version=mariadb-10.5

# Add Tini Init Process
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini

# Add CMAPI Package
RUN mkdir -p /opt/cmapi
ADD https://cspkg.s3.amazonaws.com/cmapi/pr/154/mariadb-columnstore-cmapi.tar.gz /opt/cmapi
WORKDIR /opt/cmapi
RUN tar -xvzf mariadb-columnstore-cmapi.tar.gz && rm -f mariadb-columnstore-cmapi.tar.gz && rm -rf /opt/cmapi/python
WORKDIR /

# Install MariaDB/ColumnStore packages
RUN dnf -y install \
     https://cspkg.s3.amazonaws.com/develop/396/centos8/MariaDB-shared-10.5.5-1.el8.x86_64.rpm \
     https://cspkg.s3.amazonaws.com/develop/396/centos8/MariaDB-common-10.5.5-1.el8.x86_64.rpm \
     https://cspkg.s3.amazonaws.com/develop/396/centos8/MariaDB-client-10.5.5-1.el8.x86_64.rpm \
     https://cspkg.s3.amazonaws.com/develop/396/centos8/MariaDB-server-10.5.5-1.el8.x86_64.rpm \
     https://cspkg.s3.amazonaws.com/develop/396/centos8/MariaDB-columnstore-engine-10.5.5-1.el8.x86_64.rpm

# Copy files to image
COPY config/monit.d/ /etc/monit.d/

COPY config/cmapi_server.conf /etc/columnstore/cmapi_server.conf

COPY scripts/columnstore-init \
     scripts/columnstore-start \
     scripts/columnstore-stop \
     scripts/columnstore-restart /usr/bin/

# Chmod some files
RUN chmod +x /usr/bin/tini \
    /usr/bin/columnstore-init \
    /usr/bin/columnstore-start \
    /usr/bin/columnstore-stop \
    /usr/bin/columnstore-restart && \
    sed -i 's|set daemon\s.30|set daemon 5|g' /etc/monitrc && \
    sed -i 's|#.*with start delay\s.*240|  with start delay 60|g' /etc/monitrc

# Expose MariaDB port
EXPOSE 3306

# Create persistent volumes
VOLUME ["/etc/columnstore", "/var/lib/columnstore", "/var/lib/mysql"]

# Copy entrypoint to image
COPY scripts/docker-entrypoint.sh /usr/bin/

# Make entrypoint executable & create legacy symlink
RUN chmod +x /usr/bin/docker-entrypoint.sh && \
    ln -s /usr/bin/docker-entrypoint.sh /docker-entrypoint.sh

# Clean system and reduce size
RUN dnf clean all && \
    rm -rf /var/cache/dnf && \
    find /var/log -type f -exec cp /dev/null {} \; && \
    cat /dev/null > ~/.bash_history && \
    history -c && \
    sed -i 's|SysSock.Use="off"|SysSock.Use="on"|' /etc/rsyslog.conf && \
    sed -i 's|^.*module(load="imjournal"|#module(load="imjournal"|g' /etc/rsyslog.conf && \
    sed -i 's|^.*StateFile="imjournal.state")|#  StateFile="imjournal.state"\)|g' /etc/rsyslog.conf

# Bootstrap
ENTRYPOINT ["/usr/bin/tini","--","docker-entrypoint.sh"]
CMD columnstore-start && monit -I
