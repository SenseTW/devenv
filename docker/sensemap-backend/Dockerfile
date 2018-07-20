FROM node:8

RUN apt update && \
    apt-get install -y postgresql-client && \
    apt-get clean

RUN npm install -g concurrently

RUN mkdir /workspace
WORKDIR /workspace
COPY entrypoint.sh /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]
