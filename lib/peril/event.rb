module Peril

  class Event < ActiveRecord::Base

    def self.from_h(hash)
      # Stringify the keys first, so I can use symbols in unit tests, but JSON can
      # give me Strings instead.
      hash.keys.each { |k| hash[k.to_s] = hash[k] }

      new do |e|
        e.unique_id = hash['unique_id']
        e.reporter = hash['reporter']
      end
    end
  end

end
