import overlayFormDatasets from "window_scripts/profile_forms/overlay_form_changes";
import * as setupVisibilityToggles from
  "window_scripts/profile_forms/setup_visibility_toggles"

export { overlayFormDatasets };
export { setupVisibilityToggles };

export const emphasizeLocationTabs = () => {
  $("input.location").change(function(e){
    location_name = $(e.target).attr("name");

    // 'change' captures toggle on only
    if ($(e.target).val() == "Not used") {
      $(".tabbable.location_tabs").find("." + location_name).removeClass("emphasized");
    } else {
      $(".tabbable.location_tabs").find("." + location_name).addClass("emphasized");
    }
  })
}

export const highlightNewNote = function(formData) {
  $('li[review_node_id="' + formData.reviewId + '"]').
    addClass('changed');
}

export const stashPreEditForm = () => {
  // we need to temporarily enable forbidden inputs so we can get the full serialized
  // form from them
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
  $(".submit-profiles-form").attr("disabled", false);
}
