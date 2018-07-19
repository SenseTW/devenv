FROM node:8

RUN npm install -g concurrently

RUN mkdir /workspace
WORKDIR /workspace
COPY entrypoint.sh /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]
