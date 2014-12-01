# Pull base image.
FROM debian:jessie

# Set environment.
ENV DEBIAN_FRONTEND noninteractive
ENV OPENRESTY_VER 1.7.4.1

# Install packages.
RUN apt-get update
RUN apt-get install -y build-essential curl libreadline-dev libncurses5-dev libpcre3-dev libssl-dev lua5.2 luarocks nano perl wget

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
  ldconfig

# Install luarocks modules
RUN luarocks install lua-resty-template

# Set the working directory.
WORKDIR /opt/openresty

# Expose volumes.
#VOLUME ["/etc/nginx"]

 # Install Forego
RUN wget -P /usr/local/bin https://godist.herokuapp.com/projects/ddollar/forego/releases/current/linux-amd64/forego \
 && chmod u+x /usr/local/bin/forego

# Add dockergen built in
ENV DOCKER_GEN_VERSION 0.3.6

RUN curl -L "https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz" \
 | tar -C /usr/local/bin -xvzf -

# Add files to the container.
ADD Procfile /opt/openresty/
ADD nginx.tmpl /opt/openresty/
ADD default.conf /etc/nginx/nginx.conf
RUN mkdir -p /etc/nginx/conf.d

CMD ["forego","start","-r"]
