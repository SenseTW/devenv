FROM alpine:3.7

# Install system build and runtime dependencies.
RUN apk update && apk add --no-cache \
    ca-certificates \
    collectd \
    collectd-nginx \
    libffi \
    libpq \
    nginx \
    python2 \
    py2-pip \
    nodejs \
    git

# Create the hypothesis user, group, home directory and package directory.
RUN addgroup -g 1000 -S hypothesis && adduser -u 1000 -S -G hypothesis -h /var/lib/hypothesis hypothesis
WORKDIR /var/lib/hypothesis

# Ensure nginx state and log directories writeable by unprivileged user.
RUN chown -R hypothesis:hypothesis /var/log/nginx /var/lib/nginx /var/tmp/nginx

# Copy minimal data to allow installation of dependencies.
COPY requirements.txt ./
COPY requirements.in ./
COPY requirements-dev.in ./
COPY tox.ini ./

# Install build deps, build, and then clean up.
RUN apk add --no-cache --virtual build-deps \
    build-base \
    libffi-dev \
    python-dev \
  && apk del libressl-dev \
  && apk add openssl-dev \
  && pip install cryptography==1.8.1 \
  && apk del openssl-dev \
  && apk add libressl-dev \
  && apk add postgresql-dev \
  && pip install --no-cache-dir -U pip supervisor \
  && pip install --no-cache-dir -r requirements-dev.in tox \
  && apk del build-deps

RUN npm install gulp -g

# Copy nginx config
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copy collectd config
COPY conf/collectd.conf /etc/collectd/collectd.conf
RUN mkdir /etc/collectd/collectd.conf.d \
 && chown hypothesis:hypothesis /etc/collectd/collectd.conf.d

# Expose the default port.
EXPOSE 5000

# Set the application environment
ENV PATH /var/lib/hypothesis/bin:$PATH
ENV PYTHONIOENCODING utf_8
ENV PYTHONPATH /var/lib/hypothesis:$PYTHONPATH

ADD conf/supervisord.conf /supervisord.conf
ADD entrypoint.sh /entrypoint.sh

RUN mkdir -p /var/lib/hypothesis/node_modules \
  && chown -R hypothesis:hypothesis /var/lib/hypothesis/node_modules

VOLUME /var/lib/hypothesis
VOLUME /var/lib/hypothesis/node_modules

# Start the web server by default
USER hypothesis

ENTRYPOINT ["/entrypoint.sh"]
