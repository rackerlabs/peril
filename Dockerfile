FROM google/ruby

WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock

RUN apt-get install -y libpq-dev libsqlite3-dev

RUN ["/usr/bin/bundle", "install"]
ADD . /app

# Expose port for the webhook
EXPOSE 8080

CMD ["bundle", "exec", "bin/peril-web"]
