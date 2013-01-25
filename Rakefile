require'rubygems'
gem 'activerecord'
gem 'sqlite3'
require 'active_record'
require 'sqlite3'
require 'mongo'
require 'pp'

# References
#  http://www.sqlite.org/datatype3.html

#SQLITE_DB_BASE = 'Lightroom 4 Catalog'
#SQLITE_DB = "#{SQLITE_DB_BASE}.lrcat"
SQLITE_DB_BASE = 'Chinook_Sqlite'
SQLITE_DB = "#{SQLITE_DB_BASE}.sqlite"
SQLITE_DB_SCHEMA = "#{SQLITE_DB_BASE}.schema"
SQLITE_DB_SCHEMA_RB = "#{SQLITE_DB_BASE}_schema.rb"
MONGO_DB = "mongo_skewer"

task :default => :all

task :all => [ :bundle_install, SQLITE_DB_SCHEMA, SQLITE_DB_SCHEMA_RB, :mongo_skewer ]

task :bundle_install do
  sh "bundle install"
end

task :mongo_skewer do
  sh "ruby mongo_skewer.rb '#{SQLITE_DB}' '#{MONGO_DB}'"
end

task :clobber do
  sh "rm -f '#{SQLITE_DB_SCHEMA}' '#{SQLITE_DB_SCHEMA_RB}'"
  Mongo::MongoClient.new.drop_database(MONGO_DB)
end

file SQLITE_DB_SCHEMA => SQLITE_DB do |t|
  sh "sqlite3 '#{SQLITE_DB}' .schema > '#{t}'"
end

file SQLITE_DB_SCHEMA_RB => SQLITE_DB do |t|
  sh "ruby schema_dumper_sqlite.rb '#{SQLITE_DB}' > '#{t}'"
end

task :table_example do
  ActiveRecord::Base.establish_connection(
    :adapter  => 'sqlite3',
    :database =>  SQLITE_DB
  )
  $connection = ActiveRecord::Base.connection
  table_name = 'Invoice' #$connection.tables.sort.first
  model_name = table_name.underscore.camelize
  eval <<-EOD
    class #{model_name} < ActiveRecord::Base
      self.table_name = '#{table_name}'
      def self.inheritance_column; nil; end
    end

    row = #{model_name}.find(:all).first
    puts "-------- attributes --------"
    p row.attributes
    #{model_name}.columns.each do |col|
      puts "-------- column " + col.name + " --------"
      p col
      p row.read_attribute(col.name)
    end
    puts "-------- primary key --------"
    p $connection.primary_key(table_name)
    puts "-------- indexes --------"
    p $connection.indexes(table_name)
    #puts row.methods.sort
    puts "-------- NUMERIC --------"
    p #{model_name}.columns.select{|col| col.type == :decimal}.map{|col| [col.name, :to_f]}
  EOD
end