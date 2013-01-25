#!/usr/bin/env ruby
require'rubygems'
gem 'activerecord'
gem 'sqlite3'
require 'active_record'
require 'sqlite3'

if ARGV.length < 1
  puts "usage: #{$0} sqlite_db_file_path"
  exit 1
end

sqlite_db_file_path, rest = ARGV

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database =>  sqlite_db_file_path
)
if ActiveRecord::Base.connection.tables.empty? # !ActiveRecord::Base.connected?
  puts "#{$0}: connection to database '#{sqlite_db_file_path}' failed"
  exit 2
end

# monkey patches for default column type mapped to string (varchar 255), not blob
module ActiveRecord
  module ConnectionAdapters
    class SQLiteAdapter
      def native_database_types #:nodoc:
        h = Hash.new( { :name => "varchar", :limit => 255 } ) # "blob"
        h.merge({
          :primary_key => default_primary_key_type,
          :string      => { :name => "varchar", :limit => 255 },
          :text        => { :name => "text" },
          :integer     => { :name => "integer" },
          :float       => { :name => "float" },
          :decimal     => { :name => "decimal" },
          :datetime    => { :name => "datetime" },
          :timestamp   => { :name => "datetime" },
          :time        => { :name => "time" },
          :date        => { :name => "date" },
          :binary      => { :name => "blob" },
          :boolean     => { :name => "boolean" }
	      })
      end
    end
    class Column
      def simplified_type(field_type)
        case field_type
        when /int/i
          :integer
        when /float|double/i
          :float
        when /decimal|numeric|number/i
          extract_scale(field_type) == 0 ? :integer : :decimal
        when /datetime/i
          :datetime
        when /timestamp/i
          :timestamp
        when /time/i
          :time
        when /date/i
          :date
        when /clob/i, /text/i
          :text
        when /blob/i, /binary/i
          :binary
        when /char/i, /string/i
          :string
        when /boolean/i
          :boolean
        else
          :string # :blob
        end
       end
    end
  end
end
ActiveRecord::SchemaDumper.dump

