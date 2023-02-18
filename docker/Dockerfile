FROM debian:bullseye

RUN apt-get update \
 && apt-get install -y \
    sqlite3 \
    ruby \
    ruby-dev \
    build-essential \
    libz-dev \
    libicu-dev \
    libsqlite3-dev \
    default-libmysqlclient-dev

ARG APP_HOME=/app
COPY ./Gemfile* ${APP_HOME}/
WORKDIR ${APP_HOME}
RUN gem install \
    bundler \
    rails
RUN bundle install

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
# CMD [ "tail", "-f", "/dev/null" ]