# Pull base image.
FROM debian:jessie

# Set versions of OpenResty and dockergen
ENV OPENRESTY_VER 1.7.10.1
ENV DOCKER_GEN_VERSION 0.3.9

# Set the working directory so forego sees the Procfile
WORKDIR /opt/openresty

# Expose volume for SSL certificates
VOLUME ["/etc/nginx/certs"]

# Expose volume for externally linked configurations
VOLUME ["/etc/nginx/external-conf.d"]

# Install packages.
RUN \
apt-get update \
&& apt-get install -y build-essential \
                      curl \
                      libreadline-dev \
                      libncurses5-dev \
                      libpcre3-dev \
                      libssl-dev \
                      lua5.2 \
                      luarocks \
                      nano \
                      perl \
                      wget \
&& curl -L "https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz" \
 | tar -C /usr/local/bin -xvzf - \
&& curl -L "http://openresty.org/download/ngx_openresty-$OPENRESTY_VER.tar.gz" \
 | tar -xzvf - && \
 cd ngx_openresty-* && \
 ./configure --with-pcre-jit --with-ipv6 && \
 make && \
 make install && \
 make clean && \
 cd .. && \
 rm -rf ngx_openresty-*&& \
 ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx && \
 ldconfig && \
 mkdir -p /etc/nginx/conf.d \
 && rm -rf /var/lib/apt/lists/* \
 && apt-get purge -y --auto-remove build-essential \
                                   curl \
                                   libreadline-dev \
                                   libncurses5-dev \
                                   libpcre3-dev \
                                   libssl-dev \ 
&& wget -P /usr/local/bin https://godist.herokuapp.com/projects/ddollar/forego/releases/current/linux-amd64/forego \
&& chmod u+x /usr/local/bin/forego

# Add files to the container.
COPY Procfile /opt/openresty/
COPY nginx.tmpl /opt/openresty/
COPY default.conf /etc/nginx/nginx.conf

CMD ["forego","start","-r"]
