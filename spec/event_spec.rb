require_relative 'spec_helpers'

describe Event do
  describe 'deserialization from a JSON payload' do
    it 'accepts a minimal incident creation event'
    it 'accepts an incident assignment event'
    it 'accepts an incident completion event'
    it 'accepts an incident tagging event'
  end

  it 'defaults incident_id to url'
  it 'defaults incident_id to title'
end
