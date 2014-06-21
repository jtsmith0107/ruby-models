require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    values = params.keys.map do |param,value|
      "#{param} = (?)"
    end
    where_str = values.join(" AND ")
   obj_params = DBConnection.execute(<<-SQL,*params.values)
    SELECT
    *
    FROM
    #{self.table_name}
    WHERE
      #{where_str}
    SQL
    obj_params.map do |param|
      self.new(param)
    end    
  end
    
    

end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
