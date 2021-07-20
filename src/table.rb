require 'yaml'

class Table
    attr_reader :name

    def initialize(path)
        raise 'Path cannot be empty' if path == ''
        raise 'Path cannot be nil' if path.nil?
        raise "Invalid path #{path}" if !File.file?(path)

        @name = File.basename(path, '.*')
    end
end
