(function( $ ) {
  $(document).ready(function() {
    var form = $("form.specialist_form");
    var JSONifiedForm = form.serializeJSON();
    var serializedForm = JSON.stringify(JSONifiedForm);
    var input = $("input#pre_edit_form_data");

    input.val(serializedForm);
  });
}( window.$ ))
