FROM ruby:2.4-slim-stretch

LABEL maintainer="ultrahang"
LABEL source="https://github.com/ultrahang/docker-diaspora"


ENV RAILS_ENV=production \
    UID=942 \
    GID=942

RUN apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y \
    build-essential \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libxslt-dev \
    imagemagick \
    ghostscript \
    curl \
    libmagickwand-dev \
    git \
    libpq-dev \
    nodejs \
    wget \
    libjemalloc-dev \
    && rm -rf /var/lib/apt/lists/*

RUN addgroup --GID ${GID} diaspora \
    && adduser --uid ${UID} --gid ${GID} \
    --home /diaspora --shell /bin/sh \
    --disabled-password --gecos "" diaspora

USER diaspora

WORKDIR /diaspora
RUN git clone --depth 1 -b v${DIASPORA_VER} https://github.com/diaspora/diaspora.git diaspora
RUN rm -fr diaspora/.git
RUN mv /diaspora/diaspora/* /diaspora/
RUN mkdir /diaspora/log \
    && cp config/database.yml.example config/database.yml

RUN gem install bundler \
    && script/configure_bundler \
    && bin/bundle install --full-index -j$(getconf _NPROCESSORS_ONLN)

VOLUME /diaspora/public
