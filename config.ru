#!/usr/bin/env ruby
#
# Driver script for Peril slurpers that consume HTTP webhooks.

require_relative 'lib/peril'

require 'sinatra/base'

class SlurperHooks < Sinatra::Base
  enable :logging

  get '/' do
    'Online and ready to receive.'
  end

  Peril::Main.new.webhooks(self)
end

run SlurperHooks