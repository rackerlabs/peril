require_relative 'spec_helpers'

describe Event do
  before { DatabaseCleaner.clean }
  let(:t) { Time.now }

  describe 'deserialization from a JSON payload' do
    it 'accepts a minimal incident creation event' do
      e = Event.from_h unique_id: 'some unique string', reporter: 'minitest'

      e.unique_id.must_equal 'some unique string'
      e.reporter.must_equal 'minitest'
      e.must_be :valid?
    end

    it 'accepts an incident assignment event' do
      e = Event.from_h unique_id: 'some unique string', reporter: 'minitest',
        assignee: 'someracker', assigned_at: t

      e.unique_id.must_equal 'some unique string'
      e.reporter.must_equal 'minitest'
      e.assignee.must_equal 'someracker'
      e.assigned_at.must_equal t

      e.must_be :assignment?
    end

    it 'accepts an incident completion event' do
      e = Event.from_h unique_id: 'some unique string', reporter: 'minitest',
        completed_at: t

      e.unique_id.must_equal 'some unique string'
      e.reporter.must_equal 'minitest'
      e.completed_at.must_equal t

      e.must_be :completion?
    end

    it 'accepts an incident tagging event' do
      e = Event.from_h unique_id: 'some unique string', reporter: 'minitest',
        tags: %w(ruby fog carrierwave)

      e.tags.must_equal 'ruby,fog,carrierwave'
    end

    it 'defaults unique_id to url' do
      e = Event.from_h url: 'https://stackoverflow.com/12345/oh-noes', reporter: 'minitest'

      e.url.must_equal 'https://stackoverflow.com/12345/oh-noes'
      e.title.must_equal 'https://stackoverflow.com/12345/oh-noes'
      e.unique_id.must_equal 'https://stackoverflow.com/12345/oh-noes'
    end

    it 'derives unique_id from reporter and title' do
      e = Event.from_h title: 'Oh Nooooo', reporter: 'minitest'

      e.title.must_equal 'Oh Nooooo'
      e.unique_id.must_equal 'minitest:title:Oh Nooooo'
    end

    it 'derives unique_id from reporter and origin_id' do
      e = Event.from_h origin_id: '12345', reporter: 'minitest'

      e.title.must_equal 'minitest 12345'
      e.unique_id.must_equal 'minitest:origin:12345'
    end
  end

  describe 'validations' do
    it 'must have a reporter' do
      e = Event.from_h unique_id: 'something'
      e.wont_be :valid?
    end

    it 'must have some way to derive a unique_id' do
      e = Event.from_h reporter: 'minitest'
      e.wont_be :valid?
    end
  end
end
