FROM docker.io/mongo:5.0

ENV MONGODB_VERSION=5.0 \
    HOME=/var/lib/mongo \
    SCRIPTS_PATH=/opt/bin
ENV PATH=$SCRIPTS_PATH:$PATH

# Copy entitlements
#COPY ./etc-pki-entitlement /etc/pki/entitlement

# Copy subscription manager configurations
#COPY ./rhsm-conf /etc/rhsm
#COPY ./rhsm-ca /etc/rhsm/ca

# https://repo.mongodb.org/yum/redhat/8/mongodb-org/
# mongodb-org package will install:
#   1. mongodb-org-server – MongoDB daemon mongod
#   2. mongodb-org-mongos – MongoDB Shard daemon
#   3. mongodb-org-shell – A shell to MongoDB
#   4. mongodb-org-tools – Tools (dump, restore, etc)

# Package setup
#RUN INSTALL_PKGS="numactl rsync jq hostname procps mongodb-org" && \
#    yum repolist --disablerepo=* && \
#    add-mongodb-repo && \
#    yum -y update && \
#    yum -y upgrade && \
#    subscription-manager repos --enable "rhel-8-for-x86_64-baseos-rpms" && \
#    #yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
#    yum clean all -y && \
#    rm -rf /var/cache/yum

RUN mkdir -p /opt/bin/ /opt/scripts/ 

COPY scripts/add-mongodb-repo /opt/bin/add-mongodb-repo
COPY scripts/container-entrypoint /usr/bin/container-entrypoint
COPY scripts/fix-perms /usr/bin/fix-perms
COPY scripts/run-mongod /opt/bin/run-mongod
COPY scripts/add_users.js /docker-entrypoint-initdb.d/
COPY scripts/*.js /opt/scripts/
COPY mongod.conf /etc/mongod.conf

# Install minio to allow for copying of backups to S3
#RUN curl "https://dl.min.io/client/mc/release/linux-amd64/mc" -o /usr/local/bin/mc && chmod +x /usr/local/bin/mc

# Install mongosh. Not available as a RPM in this
# repo version so we get it the hard way.
#RUN curl -sL https://downloads.mongodb.com/compass/mongosh-1.0.0-linux-x64.tgz | \
#    tar -zx && \
#    mv mongosh-1.0.0-linux-x64/bin/* /usr/bin/ && \
#    rm -rf mongosh-1.0.0-linux-x64

# Containter setup
RUN mkdir -p ${HOME}/data \
    /docker-entrypoint-initdb.d && \
    fix-perms /etc/mongod.conf ${HOME} ${SCRIPTS_PATH}

EXPOSE 27017

ENTRYPOINT ["container-entrypoint"]

CMD ["run-mongod"]

VOLUME ["/var/lib/mongodb/data"]
