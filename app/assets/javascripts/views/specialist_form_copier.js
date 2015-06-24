(function( $ ) {
  $(document).ready(function() {
    var input = $("input#pre_edit_form_data");
    var form = $("form.specialist_form");
    var JSONifiedForm = form.serializeJSON();
    var serializedForm = JSON.stringify(JSONifiedForm);

    input.val(serializedForm);
  });
}( window.$ ))
