module CustomPathHelper
  def duck_path(object)
    if object.is_a? NilClass
      ""
    else
      "/#{object.class.name.tableize}/#{object.id}"
    end
  end
end
