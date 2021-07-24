require_relative './src/db'
require_relative './src/keys/foreign_keys'

db = DB.new

users_fk = ForeignKeys.new('[]')
db.load_table_file('users.json', users_fk)

tickets_fks = ForeignKeys.new('[{"key": "assignee_id", "table": "users"}]')
db.load_table_file('tickets.json', tickets_fks)
