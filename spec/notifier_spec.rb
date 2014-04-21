require_relative 'spec_helpers'

class FakeNotifier < Notifier
  attr_accessor :called
  attr_accessor :event, :incident

  def process(event, incident)
    @event, @incident = event, incident
  end
end

describe Notifier do
  before { Notifier.clear }

  it 'registers itself with Notifier.known' do
    FakeNotifier.register
    Notifier.known.count { |n| FakeNotifier === n }.must_equal 1
  end

  it 'registers with a block' do
    FakeNotifier.register { |n| n.called = true }
    n = Notifier.known.detect { |n| FakeNotifier === n }
    n.must_be :called
  end

  it 'notifies all registered instances' do
    FakeNotifier.register
    n = Notifier.known.detect { |n| FakeNotifier === n }

    Notifier.handle 1, 2
    n.event.must_equal 1
    n.incident.must_equal 2
  end
end
