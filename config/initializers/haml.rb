# Pathways Rails3.2 upgrade note:
# For Rails 4 we may need these HAML options to prevent bad escaping if we upgrade to HAML 4.0:
# E.g. this problem.... <a href='#' onclick='$(&#39;#message .inner&#39;).load(&#39;/messages&#39;, function() { show_message(); }); return false;'>administration@pathwaysbc.ca</a>
# Haml::Template.options[:hyphenate_data_attrs] = false
# Haml::Template.options[:escape_html] = true
