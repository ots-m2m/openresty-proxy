# Pull base image.
FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

# Set versions of OpenResty and dockergen
ENV OPENRESTY_VER 1.7.4.1
ENV DOCKER_GEN_VERSION 0.3.6

# Install packages.
RUN apt-get update
RUN apt-get install -y \
                    build-essential \
                    curl \
                    libreadline-dev \
                    libncurses5-dev \
                    libpcre3-dev \
                    libssl-dev \
                    lua5.2 \
                    luarocks \
                    nano \
                    perl \
                    wget

# Compile openresty from source.
RUN \
  wget "http://openresty.org/download/ngx_openresty-$OPENRESTY_VER.tar.gz" && \
  tar -xzvf ngx_openresty-*.tar.gz && \
  rm -f ngx_openresty-*.tar.gz && \
  cd ngx_openresty-* && \
  ./configure --with-pcre-jit --with-ipv6 && \
  make && \
  make install && \
  make clean && \
  cd .. && \
  rm -rf ngx_openresty-*&& \
  ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx && \
  ldconfig && \
  mkdir -p /etc/nginx/conf.d

# Install luarocks modules
RUN luarocks install lua-resty-template

# Expose volumes for SSL certificates
VOLUME ["/etc/nginx/certs"]

 # Install latest version of forego
RUN \
 wget -P /usr/local/bin https://godist.herokuapp.com/projects/ddollar/forego/releases/current/linux-amd64/forego \
 && chmod u+x /usr/local/bin/forego

# Install pinned verison dockergen

RUN \
 curl -L "https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz" \
 | tar -C /usr/local/bin -xvzf -

# Add files to the container.
COPY Procfile /opt/openresty/
COPY nginx.tmpl /opt/openresty/
COPY default.conf /etc/nginx/nginx.conf

# Set the working directory so forego sees the Procfile
WORKDIR /opt/openresty

CMD ["forego","start","-r"]
