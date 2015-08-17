module ReactHelper
  # extracted from React-rails gem
  def react_component(name, props = {}, options = {}, &block)
    options = {:tag => options} if options.is_a?(Symbol)

    prerender_options = options[:prerender]
    if prerender_options
      raise NotImplementedError
    end

    html_options = options.reverse_merge(:data => {})
    html_options[:data].tap do |data|
      data[:react_class] = name
      data[:react_props] = (props.is_a?(String) ? props : props.to_json)
    end
    html_tag = html_options[:tag] || :div

    # remove internally used properties so they aren't rendered to DOM
    html_options.except!(:tag, :prerender)

    content_tag(html_tag, '', html_options, &block)
  end
end
