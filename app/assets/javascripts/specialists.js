var status_changed = function() 
{
  if ( $(this).val() == "5" )
  {
    //"retiring as of"
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
  $("[id=" + id + "] option[selected='selected']").each(
      function() {
          $(this).removeAttr('selected');
      }
  );
  
  $("[id=" + id + "] option:first").attr('selected','selected')
}

function reset_office(address_number)
{
  reset_select("specialist_specialist_offices_attributes_" + address_number + "_office_id");
}

function reset_hospital()
{
  reset_select("office_location_attributes_hospital_in_id");
  reset_select("clinic_location_attributes_hospital_in_id");
}

function reset_clinic()
{
  reset_select("office_location_attributes_clinic_in_id")
}

function reset_numbers(address_number)
{
  $("#specialist_specialist_offices_attributes_" + address_number + "_phone").val("");
  $("#specialist_specialist_offices_attributes_" + address_number + "_fax").val("");
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
    $('.sector_' + address_number).hide();
    reset_office(address_number);
    reset_hospital();
    reset_clinic();
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
    $('.sector_' + address_number).show();
    reset_hospital();
    reset_clinic();
  }
  else if ($('#location_' + address_number + '_In_an_office').is(':checked') || $('#location_' + address_number + '_In_an_existing_office').is(':checked'))
  {
    $('.numbers_' + address_number).show();
    $('.office_' + address_number).show();
    $('.address_' + address_number).hide();
    $('.hospital_' + address_number).hide();
    $('.clinic_' + address_number).hide();
    $('.details_' + address_number).hide();
    $('.sector_' + address_number).show();
    reset_hospital();
    reset_clinic();
  }
  else if ($('#location_' + address_number + '_In_a_hospital').is(':checked') || $('#location_' + address_number + '_In_a_new_office_in_a_hospital').is(':checked'))
  {
    $('.numbers_' + address_number).show();
    $('.office_' + address_number).hide();
    $('.address_' + address_number).hide();
    $('.hospital_' + address_number).show();
    $('.clinic_' + address_number).hide();
    $('.details_' + address_number).show();
    $('.sector_' + address_number).show();
    reset_office(address_number);
    reset_clinic();
  }
  else if ($('#location_' + address_number + '_In_a_clinic').is(':checked') || $('#location_' + address_number + '_In_a_new_office_in_a_clinic').is(':checked'))
  {
    $('.numbers_' + address_number).show();
    $('.office_' + address_number).hide();
    $('.address_' + address_number).hide();
    $('.hospital_' + address_number).hide();
    $('.clinic_' + address_number).show();
    $('.details_' + address_number).show();
    $('.sector_' + address_number).show();
    reset_office(address_number);
    reset_hospital();
  }
}

var address_0_location_changed = function() { address_location_changed(0) }
var address_1_location_changed = function() { address_location_changed(1) }

$(".location_0").live("change", address_0_location_changed );
$(".location_1").live("change", address_1_location_changed );


$("#add_address").live("click", function() {
                       $(this).hide()
                       });