module Tmdb
  class Struct < OpenStruct

    def initialize(data=nil)
      @table = {}

      if data
        data.each do |k,v|
          @table[k.to_sym] = analyze_value(v)

          new_ostruct_member(k)
        end
      end
    end

    def analyze_value(v)
      case
        when v.is_a?(Hash)
          self.class.new(v)
        when v.is_a?(Array)
          v.map do |element|
            analyze_value(element)
          end
        else
          v
      end
    end

    def new_ostruct_member(name)
      name = name.to_sym
      
      @table[name] = case name
        when :title then @table[name][0, 60]
        when :description then @table[name][0, 160]
        when :keywords then @table[name].split(" ")[0, 15].join(" ")
        else @table[name]
      end
      
      unless self.respond_to?(name)
        class << self; self; end.class_eval do
          define_method(name) {@table[name].is_a?(Hash) ? OpenStruct.new(@table[name]) : @table[name]}
        end
      end
    end

  end
end
