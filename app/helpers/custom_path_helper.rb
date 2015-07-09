module CustomPathHelper
  def duck_path(object)
    if object.is_a? NilClass
      ""
    else
      send(
        "#{object.class.name.underscore}_path",
        object
      )
    end
  end
end
