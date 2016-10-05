var address_location_changed = function(address_number)
{
  const location_is_key = $(
    `input:checked[name='specialist[specialist_offices_attributes][${address_number}][location_is]']`
  )[0].value.pwPipe(parseInt)

  if (location_is_key === 0) {
  {
    $('.numbers_' + address_number).hide();
    $('.office_' + address_number).hide();
    $('.address_' + address_number).hide();
    $('.hospital_' + address_number).hide();
    $('.clinic_' + address_number).hide();
    $('.details_' + address_number).hide();
    $('.universal_' + address_number).hide();
    reset_office(address_number);
    reset_hospital(address_number);
    reset_clinic(address_number);
    reset_numbers(address_number);
  }
  else if (location_is_key === 2)
  {
    $('.numbers_' + address_number).show();
    $('.office_' + address_number).hide();
    $('.address_' + address_number).show();
    $('.hospital_' + address_number).hide();
    $('.clinic_' + address_number).hide();
    $('.details_' + address_number).hide();
    $('.universal_' + address_number).show();
    reset_hospital(address_number);
    reset_clinic(address_number);
  }
  else if location_is_key === 1 || location_is_key === 5)
  {
    $('.numbers_' + address_number).show();
    $('.office_' + address_number).show();
    $('.address_' + address_number).hide();
    $('.hospital_' + address_number).hide();
    $('.clinic_' + address_number).hide();
    $('.details_' + address_number).hide();
    $('.universal_' + address_number).show();
    reset_hospital(address_number);
    reset_clinic(address_number);
  }
  else if (location_is_key === 3)
  {
    $('.numbers_' + address_number).show();
    $('.office_' + address_number).hide();
    $('.address_' + address_number).hide();
    $('.hospital_' + address_number).show();
    $('.clinic_' + address_number).hide();
    $('.details_' + address_number).show();
    $('.universal_' + address_number).show();
    reset_office(address_number);
    reset_clinic(address_number);
  }
  else if (location_is_key === 4)
  {
    $('.numbers_' + address_number).show();
    $('.office_' + address_number).hide();
    $('.address_' + address_number).hide();
    $('.hospital_' + address_number).hide();
    $('.clinic_' + address_number).show();
    $('.details_' + address_number).show();
    $('.universal_' + address_number).show();
    reset_office(address_number);
    reset_hospital(address_number);
  }
}


function reset_numbers(address_number)
{
  $("#specialist_specialist_offices_attributes_" + address_number + "_phone").val("");
  $("#specialist_specialist_offices_attributes_" + address_number + "_phone_extension").val("");
  $("#specialist_specialist_offices_attributes_" + address_number + "_fax").val("");
  $("#specialist_specialist_offices_attributes_" + address_number + "_direct_phone").val("");
  $("#specialist_specialist_offices_attributes_" + address_number + "_direct_phone_extension").val("");
  $("#specialist_specialist_offices_attributes_" + address_number + "_email").val("");
  $("#specialist_specialist_offices_attributes_" + address_number + "_url").val("");
  reset_select("specialist_specialist_offices_attributes_" + address_number + "_location_opened");
  $("#specialist_specialist_offices_attributes_" + address_number + "_sector_mask_4").prop('checked', true);
}

function reset_select(id)
{
  // remove "selected"
  $("[id=" + id + "] option[selected='selected']").each(function() { $(this).removeAttr('selected'); });
  $("[id=" + id + "] option:first").attr('selected','selected');
  $("#" + id).trigger('liszt:updated');
}

function reset_office(address_number)
{
  reset_select("specialist_specialist_offices_attributes_" + address_number + "_office_id");
}

function reset_hospital(address_number)
{
  //specialist edit page
  reset_select("specialist_specialist_offices_attributes_" + address_number + "_office_attributes_location_attributes_hospital_in_id");

  //offices edit
  reset_select("office_location_attributes_location_in_id");
  reset_select("office_location_attributes_hospital_in_id");
}

function reset_clinic(address_number)
{
  reset_select("specialist_specialist_offices_attributes_" + address_number + "_office_attributes_location_attributes_location_in_id");
}


var scheduled_changed = function()
{
  if ($(this).is(":checked"))
  {
    $(this).parent().siblings(".hours").show()
    $(this).parent().siblings(".break").show()
  }
  else
  {
    $(this).parent().siblings(".hours").hide()
    $(this).parent().siblings(".break").hide()
  }
}

var setConditionsToShowSection = function(parentFields, effected){
  var parentInputSelector = parentFields.map(function(field){
    return "#specialist_" + field[0];
  }).join(", ");

  $(parentInputSelector).change(function(e){
    doSideEffects(parentFields, effected);
  });
  doSideEffects(parentFields, effected)
}

var doSideEffects = function(parentFields, effected){
  if(parentFields.every(function(field) {
    return typeAdjustedInputValue(field[0]) == field[1]
  })){
    showEffected(effected);
  }
  else {
    hideEffected(effected);
  }
}

var showEffected = function(effected){
  if(effected.indexOf("section") !== -1){
    $("#" + effected).show();
  }
  else{
    $(".specialist_" + effected).show()
  }
}

var hideEffected = function(effected){
  if(effected.indexOf("section") !== -1){
    $("#" + effected).hide();
  }
  else{
    $(".specialist_" + effected).
      hide()

    var childCheckbox = $("#specialist_" + effected)[0]
    if (childCheckbox){
      $(childCheckbox).attr("checked", false)
    }
  }
}

var typeAdjustedInputValue = function(fieldname){
  field = $("#specialist_" + fieldname)

  if (field.attr("type") === "checkbox"){
    return field.prop("checked");
  }
  else {
    return field.val();
  }
}

$(document).ready(function(){
  $(".scheduled").on("change", scheduled_changed)

  _.times(4, function(index) {
    $("input[name='specialist[specialist_offices_attributes][" + index + "][location_is]']").live("click", function() {
      return address_location_changed(index);
    });
  })


})

const toggleGeneralInformationInputVisibility = () => {
  setConditionsToShowSection(
    [[ "availability", "13"], ["has_own_offices", true]],
    "accepting_new_direct_referrals"
  );
  setConditionsToShowSection(
    [
      [ "availability", "13"],
      ["has_own_offices", true],
      ["accepting_new_direct_referrals", true]
    ],
    "direct_referrals_limited"
  );
  setConditionsToShowSection([["retirement_scheduled", true]], "retirement_date");
  setConditionsToShowSection([["leave_scheduled", true]], "unavailable_from");
  setConditionsToShowSection([["leave_scheduled", true]], "unavailable_to");
}

const toggleSectionVisiblity = () => {
  setConditionsToShowSection([["has_own_offices", true]], "section_contact");
  setConditionsToShowSection([["has_own_offices", true]], "section_moa");
  setConditionsToShowSection([["has_own_offices", true]], "section_languages");
  // review
  setConditionsToShowSection(
    [
      ["has_own_offices", false],
      ["accepting_new_direct_referrals", false],
    ],
    "section_hospital_clinic_details"
  );
  setConditionsToShowSection(
    [
      ["has_own_offices", true],
      ["accepting_new_direct_referrals", true],
    ],
    "section_referrals"
  );
  setConditionsToShowSection(
    [
      ["has_own_offices", true]
    ],
    "section_for_patients"
  );
}
