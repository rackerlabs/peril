# Peril

*Match developers in need with support Rackers who can help them out.*

[![Build Status](https://travis-ci.org/rackerlabs/peril.svg?branch=master)](https://travis-ci.org/rackerlabs/peril)

Peril is a daemon that polls a
[Cloud Queue](http://docs.rackspace.com/queues/api/v1.0/cq-devguide/content/overview.html)
for *incidents* and maps them to tickets in a Rackspace ticketing system. It also watches
known incidents for changes and attempts to reconcile the state of existing tickets with
ground truth, by assigning unassigned tickets to a Racker if they respond with a known
account, for example. When changes are processed, Peril can also notify a set of webhooks
with POSTs to trigger notifications or other follow-on processes.

## Hacking

Want to hack on Peril? Running a local instance is easy:

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
