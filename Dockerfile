# 使用 Alpine Linux 作为基础镜像
FROM alpine:latest

# 安装依赖
RUN apk update && \
    apk add --no-cache \
    build-base \
    git \
    curl \
    nginx \
    bash \
    libmaxminddb-dev \
    libtool \
    automake \
    autoconf \
    pcre-dev \
    zlib-dev \
    lua-dev

# 安装 OpenResty
RUN curl -L https://openresty.org/download/openresty-1.19.9.1.tar.gz -o openresty.tar.gz && \
    tar -zxvf openresty.tar.gz && \
    cd openresty-1.19.9.1 && \
    ./configure --prefix=/usr/local/openresty && \
    make && \
    make install

# 安装 ModSecurity
RUN git clone --branch v3/master https://github.com/SpiderLabs/ModSecurity.git /usr/local/src/ModSecurity && \
    cd /usr/local/src/ModSecurity && \
    git submodule init && \
    git submodule update && \
    ./build.sh && \
    make && \
    make install

# 设置 ModSecurity 配置
# 配置文件会被挂载到容器运行时
VOLUME ["/etc/modsec"]

# 设置 OpenResty 配置
# 配置文件会被挂载到容器运行时
VOLUME ["/usr/local/openresty/nginx.conf"]

# 启动 OpenResty
CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
