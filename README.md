This project is intended to recreate the Rails active record, which allows developers to write simple high level methods that interface with the database for their application. This project uses the [sqlite3](https://github.com/sparklemotion/sqlite3-ruby) gem, which allows direct sql queries to be written embedded in ruby.

In particular this project implements

1. Methods that query the database for elements. i.e. for a Cat model (Cat.all, Cat.find 1 )
2. The query method .where, which allows a more limited query search
3. Association methods, and many of the generated methods that are made as a result of those. i.e. 'cat belongs_to owner' , Cat now has a method 'owner' to query the database for that cats owner.
