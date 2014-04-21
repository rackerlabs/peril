require_relative 'spec_helpers'

describe Incident do
  before { DatabaseCleaner.clean }
  let(:t) { Time.now }

  describe 'creation from an Event' do
    it 'creates a new unassigned Incident' do
      e = Event.from_h unique_id: 'some incident', reporter: 'minitest'

      Incident.where(unique_id: 'some incident').all.must_be :empty?
      i = Incident.for_event(e)
      i.unique_id.must_equal 'some incident'
      i.original_reporter.must_equal 'minitest'
      i.events.must_equal [e]
    end

    it 'creates an assigned Incident' do
      e = Event.from_h unique_id: 'aaa', reporter: 'minitest',
        assignee: 'racker', assigned_at: t

      i = Incident.for_event(e)
      i.must_be :assigned?
      i.wont_be :completed?
    end

    it 'creates a completed Incident' do
      e = Event.from_h unique_id: 'aaa', reporter: 'minitest',
        assignee: 'racker', assigned_at: t, completed_at: t

      i = Incident.for_event(e)
      i.wont_be :assigned?
      i.must_be :completed?
    end
  end

  describe 'update from an Event' do
    it 'appends to the Event collection'
    it "doesn't change the original_reporter"
    it 'updates other fields'
    it 'updates the assignee'
    it 'updates to the completed state'
  end
end
