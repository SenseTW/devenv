FROM node:carbon-slim

RUN mkdir /workspace
WORKDIR /workspace

RUN apt-get update -qqy && apt-get install -qqy \
        build-essential \
        bzip2 \
        make \
        curl \
        gcc \
        python-dev \
        python-setuptools \
        apt-transport-https \
        lsb-release \
        openssh-client \
        git \
        nginx \
    && easy_install -U pip && \
    pip install -U crcmod && \
    apt-get clean all && \
    npm install -g gulp

# PUT FILE
COPY install_client.sh /opt/
COPY ./client-conf /opt/client-conf
COPY nginx-site.conf /etc/nginx/sites-enabled/default

ENTRYPOINT ["/opt/install_client.sh"]
