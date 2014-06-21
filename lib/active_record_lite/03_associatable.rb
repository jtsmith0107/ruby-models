require_relative '02_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      :foreign_key => "#{name}_id".to_sym,
      :primary_key => :id,
      :class_name => name.to_s.camelcase
    }
    
    options = defaults.merge(options)
     @class_name = options[:class_name]
     @foreign_key = options[:foreign_key]
     @primary_key = options[:primary_key]
     
  end
  
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    
    defaults = {
      :foreign_key => "#{self_class_name}Id".underscore().to_sym,
      :primary_key => :id,
      :class_name => name.to_s.singularize.capitalize 
    }
    
    options = defaults.merge(options)
     @class_name = options[:class_name]
     @foreign_key = options[:foreign_key]
     @primary_key = options[:primary_key]
     
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    assoc = BelongsToOptions.new(name, options)
    define_method(name) do
      model = assoc.model_class
      #cat by foreign key
      foreign_key = send(assoc.foreign_key)
      # primary_key = assoc.send(:primary_key)
      model.where(assoc.primary_key => foreign_key).first
    end
  end

  def has_many(name, options = {})
    assoc = HasManyOptions.new(name,self.class.to_s.to_sym, options)
    define_method(name) do
      debugger
      model = assoc.model_class
      primary_key = send(assoc.primary_key)
      # primary_key = assoc.send(:primary_key)
      model.where(assoc.foreign_key => primary_key)
    end
  end

  def assoc_options
    # Wait to implement this in Phase V. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
