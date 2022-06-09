# BUILDER
FROM --platform=linux/amd64 ubuntu AS builder

RUN apt update && apt install -y wget git build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev
RUN wget http://nginx.org/download/nginx-1.21.1.tar.gz
RUN tar -xzvf nginx-1.21.1.tar.gz
RUN git clone https://github.com/chobits/ngx_http_proxy_connect_module

WORKDIR nginx-1.21.1
RUN patch -p1 < ../ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_102101.patch
RUN ./configure --add-module=../ngx_http_proxy_connect_module
RUN make && make install

# RUNNING
FROM --platform=linux/amd64 ubuntu

COPY --from=builder /nginx-1.21.1 /nginx
COPY --from=builder /usr/local/nginx /usr/local/nginx
COPY ./nginx.conf /usr/local/nginx/conf/nginx.conf

WORKDIR /nginx
EXPOSE 80/tcp
CMD ["./objs/nginx", "-g", "daemon off;"]
