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

var address_location_changed = function(address_number)
{
  if ($('#location_' + address_number + '_Stand_alone').is(':checked'))
  {
    $('.address_' + address_number).show();
    $('.hospital_' + address_number).hide();
    $('.clinic_' + address_number).hide();
    $('.details_' + address_number).hide();
    
    //need to force the hospital or clinic that might be currently selected to be not selected, as that is our address 'flag'
    
    // remove "selected" from the hospital and clinic dropdowns that might already be selected
    $("[id$=addresses_attributes_" + address_number + "_hospital_id] option[selected='selected'], [id$=addresses_attributes_" + address_number + "_clinic_id] option[selected='selected']").each(
        function() {
            $(this).removeAttr('selected');
        }
    );

    // mark the first option as selected
    $("[id$=addresses_attributes_" + address_number + "_hospital_id] option:first, [id$=addresses_attributes_" + address_number + "_clinic_id] option:first").attr('selected','selected');  
  }
  else if ($('#location_' + address_number + '_Located_in_a_hospital').is(':checked'))
  {
    $('.address_' + address_number).hide();
    $('.hospital_' + address_number).show();
    $('.clinic_' + address_number).hide();
    $('.details_' + address_number).show();
  }
  else if ($('#location_' + address_number + '_Located_in_a_clinic').is(':checked'))
  {
    $('.address_' + address_number).hide();
    $('.hospital_' + address_number).hide();
    $('.clinic_' + address_number).show();
    $('.details_' + address_number).show();
  }
}

var address_0_location_changed = function() { address_location_changed(0) }
var address_1_location_changed = function() { address_location_changed(1) }

$(".location_0").live("change", address_0_location_changed );
$(".location_1").live("change", address_1_location_changed );


$("#add_address").live("click", function() {
                       $(this).hide()
                       });