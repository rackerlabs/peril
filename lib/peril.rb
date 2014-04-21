require 'active_record'
require 'fog'

# Fail loudly if the a locale is unavailable.
I18n.config.enforce_available_locales = true

require_relative 'peril/config'
require_relative 'peril/loggable'

require_relative 'peril/event'
require_relative 'peril/queue_reader'

# Fail loudly if the a locale is unavailable.
I18n.config.enforce_available_locales = true

module Peril

  def self.table_name_prefix ; '' ; end

end
