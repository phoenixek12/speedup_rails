module SpeedUpRails
  module Collectors
    class RubyprofCollector < Collector

      def initialize
        require 'ruby-prof'
        @results_dir = Rails.root.join('tmp', 'rubyprof')
        Dir.mkdir( @results_dir ) unless File.directory?(@results_dir)
        super
      end

      def parse_options
        # pass
      end

      # The data results that are inserted at the end of the request for use in
      # deferred placeholders in the Peek the bar.
      #
      # Returns Hash.
      def results
        {}
      end

      def setup_subscribes
        before_request do
          RubyProf.start if enabled?
        end
        after_request do
          result = RubyProf.stop if enabled?

          # Print a flat profile to text
          printer = RubyProf::GraphHtmlPrinter.new(result)
          ::File.open(@results_dir.join( SpeedUpRails.request.id ), 'wb') do |file|
            printer.print(file)
          end
        end
      end


      def filter_event?(evt)
        evt.payload[:controller].start_with?('SpeedUpRails')
      end

    end
  end
end
