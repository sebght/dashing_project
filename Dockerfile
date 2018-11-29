FROM alpine:3.6

RUN apk update
RUN apk add ruby ruby-irb ruby-dev ruby-bigdecimal build-base zlib-dev nodejs git

RUN mkdir /web
ADD Gemfile /web/
ADD Gemfile.lock /web/
RUN gem install --no-rdoc --no-ri bundle bigdecimal
RUN cd /web && bundle

ADD . /web
WORKDIR /web
CMD ["dashing", "start"]
