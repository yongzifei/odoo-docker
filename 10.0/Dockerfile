FROM debian:jessie
MAINTAINER Odoo S.A. <info@odoo.com>

# explicitly set user/group IDs
RUN groupadd -r odoo --gid=888 && useradd -r -g odoo --uid=888 odoo
RUN id -u odoo

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true \
	&& apt-get purge -y --auto-remove ca-certificates wget

# Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN mkdir -p /mnt/extra-addons \
    && chown -R odoo /mnt/extra-addons ; \
    test ! -d /var/lib/odoo && mkdir -p /var/lib/odoo ;\
    chown -R odoo /var/lib/odoo;\
    test ! -d /etc/odoo && mkdir -p /etc/odoo;\
    chown -R odoo /etc/odoo;\
    test ! -d /var/log/odoo && mkdir -p /var/log/odoo;\
    chown -R odoo /var/log/odoo

VOLUME ["/var/lib/odoo", "/var/log/odoo", "/etc/odoo", "/mnt/extra-addons"]

ENV ODOO_DATA_DIR /var/lib/odoo
ENV ODOO_CONFIGURATION_DIR /etc/odoo
ENV ODOO_CONFIGURATION_FILE /etc/odoo/odoo.conf
ENV ODOO_EXTRA_ADDONS /mnt/extra-addons
ENV ODOO_LOG_DIR /var/log/odoo

# ODOO_CONFIGURATION_FILE=/etc/odoo/odoo.conf
# ODOO_GROUP="odoo"
# ODOO_DATA_DIR=/var/lib/odoo
# ODOO_LOG_DIR=/var/log/odoo
# ODOO_USER="odoo"

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            node-less \
            python-gevent \
            python-pip \
            python-renderpm \
            python-support \
            python-watchdog \
        && curl -o wkhtmltox.deb -SL http://nightly.odoo.com/extra/wkhtmltox-0.12.1.2_linux-jessie-amd64.deb \
        && echo '40e8b906de658a2221b15e4e8cd82565a47d7ee8 wkhtmltox.deb' | sha1sum -c - \
        && dpkg --force-depends -i wkhtmltox.deb \
        && apt-get -y install -f --no-install-recommends \
        && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false npm \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb \
        && pip install psycogreen==1.0

# Install Odoo
ENV ODOO_VERSION 10.0
ENV ODOO_RELEASE 20170207
RUN set -x; \
        curl -o odoo.deb -SL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
        && echo '5d2fb0cc03fa0795a7b2186bb341caa74d372e82 odoo.deb' | sha1sum -c - \
        && dpkg --force-depends -i odoo.deb \
        && apt-get update \
        && apt-get -y install -f --no-install-recommends \
        && rm -rf /var/lib/apt/lists/* odoo.deb



RUN usermod -u 888 odoo
RUN id -u odoo
# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/
RUN chown odoo /etc/odoo/odoo.conf

# Expose Odoo services
EXPOSE 8069 8072

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
