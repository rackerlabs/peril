require_relative 'spec_helpers'

class FakeSlurper < Slurper
  attr_accessor :called
  attr_reader :events

  def initialize
    @events = []
  end

  def next_events
    e = @event.shift
    e.nil? ? [] : [e]
  end
end

describe Slurper do
  before { Slurper.clear }

  it 'registers itself with Slurper.known' do
    FakeSlurper.register
    Slurper.known.count { |s| FakeSlurper === s }.must_equal 1
  end

  it 'registers with a block' do
    FakeSlurper.register { |s| s.called = true }
    s = Slurper.known.detect { |s| FakeSlurper === s }
    s.must_be :called
  end
end
