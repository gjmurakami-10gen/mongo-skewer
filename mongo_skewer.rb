#!/usr/bin/env ruby
require'rubygems'
gem 'activerecord'
gem 'sqlite3'
gem 'mongo'
require 'active_record'
require 'sqlite3'
require 'mongo'

if ARGV.size < 2
  puts "usage: #{$0} sqlite_db_file_path mongo_db_name"
  exit 1
end

sqlite_db_file_path, mongo_db_name, rest = ARGV

# TODO: review
#   NOT NULL, DEFAULT, TRIGGER

def collection_insert_slice(collection, slice, column_fix)
  collection.insert(slice.collect{|row|
    row = row.attributes.delete_if { |k, v| v.nil? }
    column_fix.each{|name, method| row[name] = row[name].send(method)}
    row
  })
end

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database =>  sqlite_db_file_path
)
$connection = ActiveRecord::Base.connection
if $connection.tables.empty? # !ActiveRecord::Base.connected?
  puts "#{$0}: connection to database '#{sqlite_db_file_path}' failed"
  exit 2
end

con = Mongo::MongoClient.new
db = con[mongo_db_name]
if db.collection_names.size > 0
  p db.collection_names
  puts "MongoDB database '#{mongo_db_name}' already exists"
  exit 3
end

table_names = $connection.tables.sort
n = table_names.size
table_names.each_with_index do |table_name, i|
  model_name = table_name.underscore.camelize
  collection = db[table_name]
  print "[#{i+1}/#{n}] table:#{table_name} model:#{model_name} "
  eval <<-EOD
    class #{model_name} < ActiveRecord::Base
      self.table_name = '#{table_name}'
      def self.inheritance_column; nil; end
    end

    $connection.indexes(table_name).each do |index|
      spec = index.columns.collect{|column| [ column, Mongo::ASCENDING ]}
      collection.ensure_index( spec, index.unique ? { :unique => true } : {} )
    end

    column_fix = #{model_name}.columns.select{|c| c.type == :decimal}.map{|c| [c.name, :to_f]}

    #{model_name}.find(:all).each_slice(1000) do |slice|
      collection_insert_slice(collection, slice, column_fix)
      print "."
    end
    print " count:"
    puts #{model_name}.count
  EOD
end
