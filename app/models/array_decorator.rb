BigDecimal.class_eval do 
  def to_json(options = {})
    self.to_f.to_json(options)
  end
end

Time.class_eval do
  def week
    self.day / 7
  end
end
