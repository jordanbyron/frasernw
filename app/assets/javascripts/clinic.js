var hideShowPhysicians = function()
{
  var currentId = $(this).attr('id');

  var specialists = "#" + currentId.replace("is_specialist","specialist_id");
  var firstname = "#" + currentId.replace("is_specialist","freeform_firstname");
  var lastname = "#" + currentId.replace("is_specialist","freeform_lastname");

  if ( $(this).is(":checked") )
  {
    //we have indicated a specialist
    $(specialists).show();
    $(firstname).hide();
    $(lastname).hide();
  }
  else
  {
    //we have indicated a freeform answer
    $(specialists).hide();
    $(firstname).show();
    $(lastname).show();
  }
}
$(document).ready(function() {
  $(".is_specialist").on("change", hideShowPhysicians );
})

var clinic_categorization_changed = function()
{
  if ($(this).val() == 1 || $(this).val() == 2)
  {
    //surveyed (may or may not have fully responded)
    $("#section_contact").show();
    $("#section_moa").show();
    $("#section_status").show();
    $("#section_aop").show();
    $("#section_referrals").show();
    $("#section_for_patients").show();
    $("#section_associations").show();
    $("#section_healthcare_providers").show();
    $("#section_admin").show();
    $("#section_deprecated").show();
  }
  else
  {
    //purposely not surveyed
    //in this case we will show their associations but nothing else, as all the rest is personal to them
    $("#section_contact").hide();
    $("#section_moa").hide();
    $("#section_status").hide();
    $("#section_aop").show();
    $("#section_referrals").hide();
    $("#section_for_patients").hide();
    $("#section_associations").show();
    $("#section_healthcare_providers").hide();
    $("#section_admin").show();
    $("#section_deprecated").show();
  }
}

$("#clinic_categorization_mask").live("change", clinic_categorization_changed)

function clinic_reset_select(id)
{
  // remove "selected"
  $("[id=" + id + "] option[selected='selected']").each(function() { $(this).removeAttr('selected'); });
  $("[id=" + id + "] option:first").attr('selected','selected')
  $("#" + id).trigger('liszt:updated');
}

function clinic_reset_standalone(address_number)
{
  clinic_reset_select("clinic_clinic_locations_attributes_" + address_number + "_location_attributes_address_attributes_city_id");
}

function clinic_reset_hospital(address_number)
{
  clinic_reset_select("clinic_clinic_locations_attributes_" + address_number + "_location_attributes_hospital_in_id");
}

function clinic_reset_numbers(address_number)
{
  $("#clinic_clinic_locations_attributes_" + address_number + "_phone").val("");
  $("#clinic_clinic_locations_attributes_" + address_number + "_phone_extension").val("");
  $("#clinic_clinic_locations_attributes_" + address_number + "_fax").val("");
  $("#clinic_clinic_locations_attributes_" + address_number + "_direct_phone").val("");
  $("#clinic_clinic_locations_attributes_" + address_number + "_direct_phone_extension").val("");
  $("#clinic_clinic_locations_attributes_" + address_number + "_email").val("");
  $("#clinic_clinic_locations_attributes_" + address_number + "_url").val("");
  $("#clinic_clinic_locations_attributes_" + address_number + "_location_attributes_suite_in").val("");
  $("#clinic_clinic_locations_attributes_" + address_number + "_location_attributes_details_in").val("");
  $("#clinic_clinic_locations_attributes_" + address_number + "_location_attributes_address_attributes_suite").val("");
  $("#clinic_clinic_locations_attributes_" + address_number + "_location_attributes_address_attributes_address1").val("");
  $("#clinic_clinic_locations_attributes_" + address_number + "_location_attributes_address_attributes_address2").val("");
  $("#clinic_clinic_locations_attributes_" + address_number + "_location_attributes_address_attributes_postalcode").val("");
  clinic_reset_select("clinic_clinic_locations_attributes_" + address_number + "_location_opened");
  $("#clinic_clinic_locations_attributes_" + address_number + "_sector_mask_4").prop('checked', true);
  $("#clinic_clinic_locations_attributes_" + address_number + "_wheelchair_accessible_mask_3").prop('checked', true);
}

var clinic_address_location_changed = function(address_number)
{
  if (is_clinic_location_status_checked(address_number, 1))
  {
    $('.numbers_' + address_number).hide();
    $('.office_' + address_number).hide();
    $('.address_' + address_number).hide();
    $('.hospital_' + address_number).hide();
    $('.clinic_' + address_number).hide();
    $('.details_' + address_number).hide();
    $('.universal_' + address_number).hide();
    clinic_reset_standalone(address_number);
    clinic_reset_hospital(address_number);
    clinic_reset_numbers(address_number);
  }
  else if (is_clinic_location_status_checked(address_number, 2))
  {
    $('.numbers_' + address_number).show();
    $('.office_' + address_number).hide();
    $('.address_' + address_number).show();
    $('.hospital_' + address_number).hide();
    $('.clinic_' + address_number).hide();
    $('.details_' + address_number).hide();
    $('.universal_' + address_number).show();
    clinic_reset_hospital(address_number);
  }
  else if (is_clinic_location_status_checked(address_number, 3))
  {
    $('.numbers_' + address_number).show();
    $('.office_' + address_number).hide();
    $('.address_' + address_number).hide();
    $('.hospital_' + address_number).show();
    $('.clinic_' + address_number).hide();
    $('.details_' + address_number).show();
    $('.universal_' + address_number).show();
  }
}

var is_clinic_location_status_checked = function(clinic_location, status_code) {
  return $('#clinic_clinic_locations_attributes_' + clinic_location + '_location_is_' + status_code).is(':checked');
}

_.times(9, function(index) {
  $("input[name='clinic[clinic_locations_attributes][" + index + "][location_is]']").live("click", function() {
    return clinic_address_location_changed(index);
  });
})
