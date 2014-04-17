require_relative 'spec_helpers'

describe Event do
  before { DatabaseCleaner.clean }

  describe 'deserialization from a JSON payload' do
    it 'accepts a minimal incident creation event' do
      e = Event.from_h unique_id: 'some unique string', reporter: 'minitest'

      e.unique_id.must_equal 'some unique string'
      e.reporter.must_equal 'minitest'
      e.must_be :valid?
    end

    it 'accepts an incident assignment event'
    it 'accepts an incident completion event'
    it 'accepts an incident tagging event'
  end

  it 'defaults unique_id to url'
  it 'defaults unique_id to title'
end
