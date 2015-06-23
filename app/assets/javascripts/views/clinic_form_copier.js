(function( $ ) {
  $(document).ready(function() {
    var form = $("form.clinic_form");
    var JSONifiedForm = form.serializeJSON();
    var serializedForm = JSON.stringify(JSONifiedForm);
    var input = $("input#pre_edit_form_data");

    console.log(serializedForm);

    input.val(serializedForm);
  });
}( window.$ ))
