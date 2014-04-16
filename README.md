# Peril

*Match developers in need with support Rackers who can help them out.*

Peril is a daemon that polls a
[Cloud Queue](http://docs.rackspace.com/queues/api/v1.0/cq-devguide/content/overview.html)
for *incidents* and maps them to tickets in a Rackspace ticketing system. It also watches
known incidents for changes and attempts to reconcile the state of existing tickets with
ground truth, by assigning unassigned tickets to a Racker if they respond with a known
account, for example. When changes are processed, Peril can also notify a set of webhooks
with POSTs to trigger notifications or other follow-on processes.
