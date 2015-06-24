(function( $ ) {
  $(document).ready(function() {
    var input = $("input#pre_edit_form_data");

    // Hack with the disabled inputs because they're not picked up by
    // the jquery plugin
    var disabledInputs = $("input[disabled='disabled']");
    disabledInputs.attr("disabled", false);
    var form = $("form.specialist_form");
    var JSONifiedForm = form.serializeJSON();
    disabledInputs.attr("disabled", true);

    var serializedForm = JSON.stringify(JSONifiedForm);
    input.val(serializedForm);
  });
}( window.$ ))
