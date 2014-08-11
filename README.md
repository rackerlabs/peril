# Peril

*Match developers in need with support Rackers who can help them out.*

[![Build Status](https://travis-ci.org/rackerlabs/peril.svg?branch=master)](https://travis-ci.org/rackerlabs/peril)

Peril is a service to discover and coordinate support offered in unconventional places, like StackOverflow or mailing lists. It lets us stay aware of an expanding number of places that developers can use to approach us for help without filling our browser bookmarks and RSS feeds.

Its goal is to match developers with questions to the Racker with the right answer. It'll keep us from dogpiling a single email with responses, or neglect anyone because we all assume someone else is handling it. I'm also intending to use it to automatically maintain a consistent "source of truth"; if one of us answers a question on StackOverflow, it should assign the corresponding ticket appropriately.

Peril consists of a family of *slurpers* that either poll for new events from some API, or wait for incoming webhooks. Slurpers produce a stream of `Events`, which are mapped to existing or new `Incidents`. `Incidents` are then passed to any registered *notifiers*, which can do things like post a chat message or update a ticket.

## Hacking

Want to hack on Peril? Here's how to get started.

First, you'll need [git](http://git-scm.com/downloads) and a [sane Ruby installation](https://www.ruby-lang.org/en/installation/). There are a many choices for installing both. Personally, on my Mac, I use [homebrew](http://brew.sh/) to install git and [rbenv](https://github.com/sstephenson/rbenv) + [ruby-build](https://github.com/sstephenson/ruby-build#readme) for Rubies. However you choose your setup, make sure you end up with a recent Ruby - I'm currently on 2.1.2.

```bash
# Install Bundler.
gem install bundler

# Clone it!
cd ${PROJECTS_HOME}
git clone git@github.com:rackerlabs/peril.git
cd peril

# Install dependencies.
bundle install

# To configure logging and database stuff:
#
# cp peril.example.yml peril.yml
# ${EDITOR} peril.yml

# By default, only the LoggerNotifier is registered.
# To configure active notifiers:
#
# cp notifications.rb.example notifications.rb
# ${EDITOR} notifications.rb

# By default, no slurpers are active.
# To configure active slurpers:
#
cp slurpers.rb.example slurpers.rb
${EDITOR} slurpers.rb

# Run the polling process.
#
# This will call #next_events in each Slurper and broadcast each returned event to all notifiers.
# Note that this will take over the terminal you run it in for output.
#
bundle exec ruby bin/peril-poll

# Run the webhook consumer.
#
# This will listen for incoming webhooks and dispatch them to the Slurpers that registered them.
# Note that this will take over the terminal you run it in for output.
#
bundle exec ruby bin/peril-web
```
