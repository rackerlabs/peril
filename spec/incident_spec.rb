require_relative 'spec_helpers'

describe Incident do
  before { DatabaseCleaner.clean }
  let(:t) { Time.now }

  describe 'creation from an Event' do
    it 'creates a new unassigned Incident' do
      e = Event.from_h unique_id: 'some incident', reporter: 'minitest'

      Incident.where(unique_id: 'some incident').must_be_nil
      i = Incident.for_event(e)
      i.unique_id.must_equal 'some incident'
      i.original_reporter.must_equal 'minitest'
      i.events.must_equal [e]
    end

    it 'creates an assigned Incident'
    it 'creates a completed Incident'
  end

  describe 'update from an Event' do
    it 'appends to the Event collection'
    it 'updates the assignee'
    it 'updates to the completed state'
  end
end
