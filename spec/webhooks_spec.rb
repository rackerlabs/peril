require_relative 'spec_helpers'

require 'sinatra/base'
require 'rack/test'
require 'json'

class WebSlurper < Slurper
  def initialize
    webhook do
      get('/thing') { 'yep' }
    end
  end
end

WebSlurper.register

class TestApp < Sinatra::Base
  Main.new.webhooks(self)
end

describe 'Webhooks' do
  include Rack::Test::Methods

  def app
    TestApp.new
  end

  describe 'from a slurper' do
    it 'delegates to the slurper' do
      get '/thing'

      last_response.must_be :ok?
      last_response.body.must_equal 'yep'
    end
  end

  describe 'incident listing' do
    it 'lists recently updated incidents' do
      ts = Time.at(1408475116)

      Incident.create! unique_id: 'aaa', original_reporter: 'minitest', created_at: ts - 10, updated_at: ts - 10
      Incident.create! unique_id: 'bbb', original_reporter: 'minitest', created_at: ts, updated_at: ts + 10
      Incident.create! unique_id: 'ccc', original_reporter: 'minitest', created_at: ts - 10, updated_at: ts + 20

      get '/incidents', since: ts.to_i

      last_response.must_be :ok?
      doc = JSON.parse(last_response.body)
    end

  end

end
