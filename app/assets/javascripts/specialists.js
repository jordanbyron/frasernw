var status_changed = function() 
{
  if ( $(this).val() == "4" || $(this).val() == "5" )
  {
    //"retired as of" or "retiring as of"
    $(".unavailable_from").show();
    $(".unavailable_to").hide();
  }
  else if ( $(this).val() == "6" )
  {
    //"unavaiable between"
    $(".unavailable_from").show();
    $(".unavailable_to").show();
  }
  else
  {
    $(".unavailable_from").hide();
    $(".unavailable_to").hide();
  }
}

$("#specialist_status_mask").live("change", status_changed );

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
  reset_select("specialist_specialist_offices_attributes_" + address_number + "_office_attributes_location_attributes_location_in_id");
  
  //offices edit
  reset_select("office_location_attributes_location_in_id");
  reset_select("office_location_attributes_hospital_in_id");
}

function reset_clinic(address_number)
{
  reset_select("office_location_attributes_" + address_number + "_clinic_in_id")
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
}

var address_location_changed = function(address_number)
{
  if ($('#location_' + address_number + '_Not_used').is(':checked'))
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
  else if ($('#location_' + address_number + '_Standalone').is(':checked') || $('#location_' + address_number + '_In_a_new_standalone_office').is(':checked'))
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
  else if ($('#location_' + address_number + '_In_an_office').is(':checked') || $('#location_' + address_number + '_In_an_existing_office').is(':checked'))
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
  else if ($('#location_' + address_number + '_In_a_hospital').is(':checked') || $('#location_' + address_number + '_In_a_new_office_in_a_hospital').is(':checked'))
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
  else if ($('#location_' + address_number + '_In_a_clinic').is(':checked') || $('#location_' + address_number + '_In_a_new_office_in_a_clinic').is(':checked'))
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

$(".location_0").live("change", function() { address_location_changed(0) });
$(".location_1").live("change", function() { address_location_changed(1) });
$(".location_2").live("change", function() { address_location_changed(2) });

$("#add_address").live("click", function() 
{
  $(this).hide()
});

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

$(".scheduled").live("change", scheduled_changed)

var specialist_categorization_changed = function()
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
    $("#section_hospital_clinic_details").hide();
    $("#section_associations").show();
    $("#section_admin").show();
  }
  else
  {
    //only works in clinics or hospitals, or purposely not surveyed
    //in this case we will show their associations but nothing else, as all the rest is personal to them 
    $("#section_contact").hide();
    $("#section_moa").hide();
    $("#section_status").hide();
    $("#section_aop").show();
    $("#section_referrals").hide();
    $("#section_for_patients").hide();
    $("#section_hospital_clinic_details").show();
    $("#section_associations").show();
    $("#section_admin").show();
  }
}

$("#specialist_categorization_mask").live("change", specialist_categorization_changed)
