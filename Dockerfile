FROM ruby:2.6.3-alpine

RUN apk --update add --virtual build_deps \
    build-base ruby-dev libc-dev linux-headers \
    openssl-dev libxml2-dev libxslt-dev

RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

WORKDIR /app

COPY Gemfile* ./
RUN bundle install

ENV KUBECTL_VERSION=1.11.10

COPY . .

USER 1000

