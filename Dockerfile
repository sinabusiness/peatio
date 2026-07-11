FROM ruby:3.3.0-alpine as base

LABEL maintainer="exchange.صراف.com"

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV} APP_HOME=/home/app TZ=UTC

RUN apk add --no-cache mysql-client mariadb-dev mariadb-connector-c-dev build-base

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

COPY Gemfile Gemfile.lock $APP_HOME/
RUN gem install bundler:2.5.10 && bundle config build.mysql2 --with-ldflags=-L/usr/lib && bundle install --jobs 4

COPY . $APP_HOME
RUN bundle exec rake tmp:create 2>/dev/null || true

EXPOSE 3000
CMD ["bundle", "exec", "puma", "--config", "config/puma.rb"]
