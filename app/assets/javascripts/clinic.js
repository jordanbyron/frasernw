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

$(".is_specialist").live("change", hideShowPhysicians );

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
}

function clinic_reset_hospital()
{
  //clinic_reset_select("clinic_location_attributes_hospital_in_id");
}

function clinic_reset_numbers(address_number)
{
  $("#clinic_clinic_locations_attributes_" + address_number + "_phone").val("");
  $("#clinic_clinic_locations_attributes_" + address_number + "_phone_extension").val("");
  $("#clinic_clinic_locations_attributes_" + address_number + "_fax").val("");
  $("#clinic_clinic_locations_attributes_" + address_number + "_direct_phone").val("");
  $("#clinic_clinic_locations_attributes_" + address_number + "_direct_phone_extension").val("");
}

var clinic_address_location_changed = function(address_number)
{
  if ($('#clinic_location_' + address_number + '_Not_used').is(':checked'))
  {
    $('.numbers_' + address_number).hide();
    $('.office_' + address_number).hide();
    $('.address_' + address_number).hide();
    $('.hospital_' + address_number).hide();
    $('.clinic_' + address_number).hide();
    $('.details_' + address_number).hide();
    $('.universal_' + address_number).hide();
    clinic_reset_hospital();
    clinic_reset_numbers(address_number);
  }
  else if ($('#clinic_location_' + address_number + '_Standalone').is(':checked'))
  {
    $('.numbers_' + address_number).show();
    $('.office_' + address_number).hide();
    $('.address_' + address_number).show();
    $('.hospital_' + address_number).hide();
    $('.clinic_' + address_number).hide();
    $('.details_' + address_number).hide();
    $('.universal_' + address_number).show();
    clinic_reset_hospital();
  }
  else if ($('#clinic_location_' + address_number + '_In_a_hospital').is(':checked'))
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

$(".clinic_location_0").live("change", function() { clinic_address_location_changed(0) });
$(".clinic_location_1").live("change", function() { clinic_address_location_changed(1) });
$(".clinic_location_2").live("change", function() { clinic_address_location_changed(2) });
$(".clinic_location_3").live("change", function() { clinic_address_location_changed(3) });
$(".clinic_location_4").live("change", function() { clinic_address_location_changed(4) });
$(".clinic_location_5").live("change", function() { clinic_address_location_changed(5) });
$(".clinic_location_6").live("change", function() { clinic_address_location_changed(6) });
$(".clinic_location_7").live("change", function() { clinic_address_location_changed(7) });
