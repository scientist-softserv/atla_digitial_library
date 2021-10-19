FROM ruby:2.5.3

RUN apt-get update -qq && \
    apt-get -y install apt-transport-https && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs vim libreoffice imagemagick unzip ghostscript nodejs yarn ffmpeg exiftool libvips-dev && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    yarn config set no-progress && \
    yarn config set silent

# If changes are made to fits version or location,
# amend `LD_LIBRARY_PATH` in docker-compose.yml accordingly.
RUN mkdir -p /opt/fits && \
    curl -fSL -o /opt/fits/fits-latest.zip https://github.com/harvard-lts/fits/releases/download/1.4.0/fits-latest.zip && \
    cd /opt/fits && unzip fits-latest.zip && chmod +X /opt/fits/fits.sh && \
    cp -r /opt/fits/* /usr/local/bin/

RUN mkdir /opt/csv
RUN mkdir /data
WORKDIR /data
ADD Gemfile /data/Gemfile
ADD Gemfile.lock /data/Gemfile.lock
# for engine dev only
#ADD vendor/engines/bulkrax /data/vendor/engines/bulkrax

ENV BUNDLE_JOBS=4
RUN bundle install
ADD . /data
RUN cd /data && yarn install
RUN cd /data && NODE_ENV=production DB_ADAPTER=nulldb bundle exec rake assets:clobber assets:precompile
EXPOSE 3000

CMD ["bin/rails", "console"]
