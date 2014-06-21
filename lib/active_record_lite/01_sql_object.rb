require_relative 'db_connection'
require 'active_support/inflector'
require 'debugger'

#NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
#    of this project. It was only a warm up.

class SQLObject

  def self.columns
    columns = DBConnection.execute2("SELECT * FROM #{self.to_s}s").first.map do |column|
      column.to_sym
    end
    
    columns.each do |column|
      define_method("#{column}")do 
        #atr_hash = instance_variable_get("@attributes")
        attributes[column]        
      end
    end
    
    columns.each do |column|
      define_method "#{column}=" do |new_val|
        #atr_hash = instance_variable_get("@attributes")
        attributes[column] = new_val
      end
    end
    columns
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all    
    query =   <<-SQL
    SELECT
    #{self.table_name}.*
    FROM
    #{self.table_name}
    SQL
    
    self.parse_all(DBConnection.execute(query))
  end
  
  def self.parse_all(results)
    results.map do |row|
      self.new(row)
    end
  end

  def self.find(id)
    query = DBConnection.execute(<<-SQL, id)
    SELECT
    *
    FROM
    #{self.table_name}
    WHERE
    id = (?)
    SQL
    self.new(query.first)
  end

  def attributes
    @attributes ||= Hash.new() {|h,k| h[k] = nil}
  end

  def insert    
    col_names = self.class.columns
    
    col_names_join = col_names.drop(1).join(",")
    question_marks = (["?"] * (col_names.count-1)).join(',')
  
    att_vals = attribute_values
    
    att_vals.delete_at(0)
    DBConnection.execute(<<-SQL, *att_vals)
    INSERT INTO
    #{self.class.table_name} (#{col_names_join})
    VALUES
    (#{question_marks})
    SQL
    puts "calling last insert row id"
    @attributes[:id] = DBConnection.last_insert_row_id
  end

  def attribute_values  
    values = self.class.columns
    values.map do |column|
      self.send(column)
    end    
  end

  def initialize(params = {})
    attributes
    columns = self.class.columns
    params.each do |attr_name, value|
      if !columns.include?(attr_name.to_sym)
        raise StandardError, "unknown attribute '#{attr_name}'" 
      else
        self.send("#{attr_name.to_sym}=",value)
      end   
    end

  end

  def save
    if @attributes[:id].nil?
      insert
    else
      update
    end
  end

  def update
    col_names = self.class.columns
    col_names.delete(:id)
    col_names_str = ""
    col_names.each do |col_name|
      col_names_str += "#{col_name} = ?,"
    end
    col_names_str = col_names_str[0..-2]
    att_vals = attribute_values
    att_vals.delete_at(0)
    DBConnection.execute(<<-SQL, *att_vals)
    UPDATE
    #{self.class.table_name} 
    SET
    #{col_names_str}
    WHERE
    id = #{@attributes[:id]}
    SQL
  end

end
