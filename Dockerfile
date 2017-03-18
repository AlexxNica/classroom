FROM ruby:2.4.0
MAINTAINER tarebyte@github.com

# Install apt based dependencies required to run Rails as
# well as RubyGems. As the Ruby image itself is based on a
# Debian image, we use apt-get to install those.
RUN apt-get update
RUN apt-get install -y --no-install-recommends build-essential netcat nodejs libpq-dev
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure the main working directory. This is the base
# directory used in any further RUN, COPY, and ENTRYPOINT
# commands.
RUN mkdir -p /usr/src/classroom
WORKDIR /usr/src/classroom

# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY Gemfile Gemfile.lock /usr/src/classroom/

RUN gem install bundler
RUN gem update bundler

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1
RUN bundle install --jobs 20 --retry 5 --binstubs

# Copy our main application
COPY . /usr/src/classroom
