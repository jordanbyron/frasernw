class StringInput < SimpleForm::Inputs::StringInput
  def input_html_options
    super.merge! :maxlength => 250
  end
end