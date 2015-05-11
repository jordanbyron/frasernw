module TabsHelper
  def tablist_item(options = {})
    options[:class] ||= []
    options[:class] << "active" if options.delete(:active)
    options[:class] << "emphasized" if options.delete(:emphasized)

    content_tag :li, options do
      yield if block_given?
    end
  end
end
