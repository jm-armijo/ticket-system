require_relative 'src/loader'

loader = Loader.new
loader.load_file('tickets.json')
loader.load_file('users.json')
