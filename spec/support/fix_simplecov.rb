# -*- encoding : utf-8 -*-
if ENV['COVERAGE']
  SimpleCov::Formatter::HTMLFormatter

  class SimpleCov::Formatter::HTMLFormatter
    def format(result)
      Dir[File.join(File.dirname(__FILE__), '../public/*')].each do |path|
        FileUtils.cp_r(path, asset_output_path)
      end

      File.open(File.join(output_path, 'index.html'), file_mode_format) do |file|
        file.puts template('layout').result(binding)
      end
      puts output_message(result)
    end

    def file_mode_format
      format = 'w+'

      # On JRuby/Windows it tries to convert all \n into \r\n in w+ mode.
      # b mode is binary and outputs "as is".
      if defined?(JRUBY_VERSION) && !!(RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/i)
        format = 'wb+'
      end

      format
    end
  end
end
