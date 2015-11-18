// Handles operations related to saving clinic, specialist form params
// - saves pre-edit form params on a hidden input
// - ensures disabled inputs are sent to rails

(function( $ ) {
  $(document).ready(function() {
    var forbiddenInputs = $(
      "input[disabled='disabled'], select[disabled='disabled'], textarea[disabled='disabled']"
    )
    forbiddenInputs.attr("disabled", false);

    var form = $("form.clinic_form, form.specialist_form");
    var JSONifiedForm = form.serializeJSON();
    var serializedForm = JSON.stringify(JSONifiedForm);

    forbiddenInputs.attr("disabled", "disabled");

    var preEditStash = $("input#pre_edit_form_data");
    preEditStash.val(serializedForm);

    form.on("submit", function(e) {
      e.preventDefault();
      forbiddenInputs.attr("disabled", false);
      this.submit();
    });

    // only allow them to submit the form once all this is done
    $(".submit-referents-form").attr("disabled", false);
  });
}( window.$ ))
