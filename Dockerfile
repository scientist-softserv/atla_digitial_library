FROM ruby:2.5.3

RUN apt-get update && apt-get -y install apt-transport-https

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs vim libreoffice imagemagick unzip ghostscript nodejs yarn && \
    rm -rf /var/lib/apt/lists/*

# If changes are made to fits version or location,
# amend `LD_LIBRARY_PATH` in docker-compose.yml accordingly.
RUN mkdir -p /opt/fits && \
    curl -fSL -o /opt/fits/fits-latest.zip https://github.com/harvard-lts/fits/releases/download/1.4.0/fits-latest.zip && \
    cd /opt/fits && unzip fits-latest.zip && chmod +X /opt/fits/fits.sh && \
    cp -r /opt/fits/* /usr/local/bin/

RUN mkdir /data
WORKDIR /data
ADD Gemfile /data/Gemfile
ADD Gemfile.lock /data/Gemfile.lock
# for engine dev only
# ADD vendor/engines/bulkrax /data/vendor/engines/bulkrax

ENV BUNDLE_JOBS=4
RUN bundle install
ADD . /data
#RUN  cd /data && NODE_ENV=production DB_ADAPTER=nulldb bundle exec rake assets:clobber assets:precompile
EXPOSE 3000

CMD ["bin/rails", "console"]
