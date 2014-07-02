require 'yaml'
require 'fileutils'

module Peril
  module Slurpers

    class Dirslurp < Slurper
      include Loggable

      def initialize
        @directories = []
      end

      def directory(path)
        @directories << path
      end

      def glob(str)
        @glob = str
      end

      def setup
        if @directories.empty?
          raise RuntimeError.new("Dirslurp requires at least one directory.")
        end

        @directories.each do |dir|
          unless File.directory?(dir) && File.readable?(dir)
            raise RuntimeError.new("#{dir} isn't a valid, readable directory.")
          end
        end

        @glob ||= '*.yml'
      end

      def next_events
        logger.info "Polling for file-based events."

        events = []
        @directories.each do |dir|
          logger.debug "Checking #{dir}."

          dir_loaded = 0
          Dir[File.join(dir, @glob)].each do |path|
            logger.debug "Loading events from #{path}."
            workpath = "#{path}.loading"

            begin
              FileUtils.mv path, workpath
              es = YAML.load_file(workpath).map { |e| Event.from_h(e) }
              dir_loaded += es.size
              events += es
              FileUtils.rm workpath
            rescue e
              logger.error "Kaboom from #{path}! #{e}"
            end
          end

          logger.info "Loaded #{dir_loaded} events from #{dir}."
        end

        logger.info "Loaded #{events.size} total events."

        events
      end
    end

  end
end
