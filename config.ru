#!/usr/bin/env ruby
#
# Driver script for Peril slurpers that consume HTTP webhooks.

require_relative 'lib/peril'

require 'sinatra/base'

class SlurperHooks < Sinatra::Base
  enable :loggings

  Peril::Main.new.webhooks(self)
end

run SlurperHooks
