class TipModifier < Struct.new(:name, :value)
  def self.find_in_message(message)
    return nil unless CONFIG["modifiers"]

    modifier_name, modifier = CONFIG["modifiers"].detect do |name,|
      message =~ /##{Regexp.escape(name)}/
    end

    if modifier_name
      new(modifier_name, modifier)
    else
      nil
    end
  end
end
