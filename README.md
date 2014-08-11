# Peril

*Match developers in need with support Rackers who can help them out.*

[![Build Status](https://travis-ci.org/rackerlabs/peril.svg?branch=master)](https://travis-ci.org/rackerlabs/peril)

Peril is a service to discover and coordinate support offered in unconventional places, like StackOverflow or mailing lists. It lets us stay aware of an expanding number of places that developers can use to approach us for help without filling our browser bookmarks and RSS feeds.

Its goal is to match developers with questions to the Racker with the right answer. It'll keep us from dogpiling a single email with responses, or neglect anyone because we all assume someone else is handling it. I'm also intending to use it to automatically maintain a consistent "source of truth"; if one of us answers a question on StackOverflow, it should assign the corresponding ticket appropriately.

Peril consists of a family of *slurpers* that either poll for new events from some API, or wait for incoming webhooks. Slurpers produce a stream of `Events`, which are mapped to existing or new `Incidents`. `Incidents` are then passed to any registered *notifiers*, which can do things like post a chat message or update a ticket.

## Hacking

Want to hack on Peril? Here's how to get started.

```bash
cd ${PROJECTS_HOME}
git clone git@github.com:rackerlabs/peril.git
cd peril

# You'll need to fill in a few configuration options.
cp peril.yml.example peril.yml
${EDITOR} peril.yml

cp notifications.rb.example notifications.rb
# Optionally:
# ${EDITOR} notifications.rb

# Install dependencies.
bundle install

# Kick it off.
bundle exec bin/peril

# In another terminal, you can run this to seed the Cloud Queue with fake events:
bundle exec bin/seed
```
