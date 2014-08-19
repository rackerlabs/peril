require_relative 'spec_helpers'

require 'sinatra/base'
require 'rack/test'

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

end
