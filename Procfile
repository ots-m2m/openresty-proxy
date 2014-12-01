nginx: nginx -c /etc/nginx/nginx.conf
dockergen: docker-gen -watch -only-exposed -notify "nginx -s reload" /opt/openresty/nginx.tmpl /etc/nginx/conf.d/default.conf
