# Description

mongo_skewer is a yet another simple utility to import a SQL database into MongoDB.
It is written in Ruby using ActiveRecord so that it is simple and easy to customize.

After import, continue to refine and transform your schema to match the
consistency, performance, and scaling requirements of your application.

In general, normalize for consistency, and denormalize for performance.  Denormalizing
follows practices like caching and memoizing, use techniques like background updates or
look-aside caches as needed.

# Prerequisites

1. Ruby
2. Rake
3. SQLite - http://www.sqlite.org/
4. PostgreSQL - http://www.postgresql.org/
5. MySQL - http://www.mysql.com/

# Usage

To install gems and run tests

    $ rake

To clean up so that you can rerun or for distribution

    $ rake clobber

To import a database from SQLite to MongoDB

    $ mongo_skewer sqlite_db_file_path mongo_db_name

where _sqlite_db_file_path_ is the path to your SQLite database file
and _mongo_db_name_ is the name of the MongoDB database to create.
The primary key column name is carried through so that it can be identified easily,
it is purposely not used for the _id field.

# References

Chinook Database - http://chinookdatabase.codeplex.com/

# TO DO

1. script/mongo_rails_import - import script to drop into an existing Rails project
2. PostgreSQL
3. MySQL

