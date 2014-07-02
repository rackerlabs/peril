require 'active_record'

# Fail loudly if a locale is unavailable.
I18n.config.enforce_available_locales = true

require_relative 'peril/config'
require_relative 'peril/loggable'
require_relative 'peril/plugin_set'
require_relative 'peril/pluggable'

require_relative 'peril/notifier'
require_relative 'peril/slurper'

require_relative 'peril/event'
require_relative 'peril/incident'

require_relative 'peril/main'

module Peril

  def self.table_name_prefix ; '' ; end

end
