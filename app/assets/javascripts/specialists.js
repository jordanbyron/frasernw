var status_changed = function()
{
  if ( $(this).val() == "4" || $(this).val() == "5" || $(this).val() == "9" || $(this).val() == "10" )
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

  //offices edit
  reset_select("office_location_attributes_location_in_id");
  reset_select("office_location_attributes_hospital_in_id");
}

function reset_clinic(address_number)
{
  reset_select("specialist_specialist_offices_attributes_" + address_number + "_office_attributes_location_attributes_location_in_id");
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

var is_specialist_office_status_checked = function(specialist_office, status_code) {
  return $('#specialist_specialist_offices_attributes_' + specialist_office + '_location_is_' + status_code).is(':checked');
}

var address_location_changed = function(address_number)
{
  if (is_specialist_office_status_checked(address_number, 0))
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
  else if (is_specialist_office_status_checked(address_number, 2))
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
  else if (is_specialist_office_status_checked(address_number, 1) || is_specialist_office_status_checked(address_number, 5))
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
  else if (is_specialist_office_status_checked(address_number, 3))
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
  else if (is_specialist_office_status_checked(address_number, 4))
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

_.times(4, function(index) {
  $("input[name='specialist[specialist_offices_attributes][" + index + "][location_is]']").live("click", function() {
    return address_location_changed(index);
  });
})

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
  //these map to specialist CATEGORIZATION_LABELS
  if ($(this).val() == 1 || $(this).val() == 2 || $(this).val() == 5)
  {
    //surveyed (may or may not have fully responded)
    $("#section_contact").show();
    $("#section_moa").show();
    if ($(this).val() == 5)
    {
      //if we are "only take referrals through hospital or clinic" then our status should be determined by that
      $("#section_status").hide();
      $("#section_hospital_clinic_details").show();
      $("#section_referrals").hide();
    }
    else
    {
      $("#section_status").show();
      $("#section_hospital_clinic_details").hide();
      $("#section_referrals").show();
    }
    $("#section_aop").show();
    $("#section_for_patients").show();
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
