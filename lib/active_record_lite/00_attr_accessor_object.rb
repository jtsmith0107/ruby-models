class AttrAccessorObject
  def self.my_attr_accessor(*names)
    #get methods def name
    names.each do |name|     
      define_method name do 
        new_ivar = "@#{name}"
        instance_variable_get(new_ivar)
      end
    end
    #set methods def name=
    names.each_index do |idx|
      define_method "#{names[idx]}=" do |new_value|
        new_ivar = "@#{names[idx]}"
        instance_variable_set(new_ivar, new_value)
      end
    end
  end
end
