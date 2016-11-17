export default function updateClinicLocation(){
  const locationIsKey = $(`input:checked[name='${this.name}']`)[0].
    value.
    pwPipe(parseInt)

  const locationIndex = this.getAttribute("data-location-index");

  if (locationIsKey === 1){
    $('.numbers_' + locationIndex).hide();
    $('.office_' + locationIndex).hide();
    $('.address_' + locationIndex).hide();
    $('.hospital_' + locationIndex).hide();
    $('.clinic_' + locationIndex).hide();
    $('.details_' + locationIndex).hide();
    $('.universal_' + locationIndex).hide();
    clinic_reset_standalone(locationIndex);
    clinic_reset_hospital(locationIndex);
    clinic_reset_numbers(locationIndex);
  }
  else if (locationIsKey === 2){
    $('.numbers_' + locationIndex).show();
    $('.office_' + locationIndex).hide();
    $('.address_' + locationIndex).show();
    $('.hospital_' + locationIndex).hide();
    $('.clinic_' + locationIndex).hide();
    $('.details_' + locationIndex).hide();
    $('.universal_' + locationIndex).show();
    clinic_reset_hospital(locationIndex);
  }
  else if (locationIsKey === 3){
    $('.numbers_' + locationIndex).show();
    $('.office_' + locationIndex).hide();
    $('.address_' + locationIndex).hide();
    $('.hospital_' + locationIndex).show();
    $('.clinic_' + locationIndex).hide();
    $('.details_' + locationIndex).show();
    $('.universal_' + locationIndex).show();
  }
}

function clinic_reset_numbers(locationIndex)
{
  $("#clinic_clinic_locations_attributes_" + locationIndex + "_phone").val("");
  $("#clinic_clinic_locations_attributes_" + locationIndex + "_phone_extension").val("");
  $("#clinic_clinic_locations_attributes_" + locationIndex + "_fax").val("");
  $("#clinic_clinic_locations_attributes_" + locationIndex + "_direct_phone").val("");
  $("#clinic_clinic_locations_attributes_" + locationIndex + "_direct_phone_extension").val("");
  $("#clinic_clinic_locations_attributes_" + locationIndex + "_email").val("");
  $("#clinic_clinic_locations_attributes_" + locationIndex + "_url").val("");
  $("#clinic_clinic_locations_attributes_" + locationIndex + "_location_attributes_suite_in").val("");
  $("#clinic_clinic_locations_attributes_" + locationIndex + "_location_attributes_details_in").val("");
  $("#clinic_clinic_locations_attributes_" + locationIndex + "_location_attributes_address_attributes_suite").val("");
  $("#clinic_clinic_locations_attributes_" + locationIndex + "_location_attributes_address_attributes_address1").val("");
  $("#clinic_clinic_locations_attributes_" + locationIndex + "_location_attributes_address_attributes_address2").val("");
  $("#clinic_clinic_locations_attributes_" + locationIndex + "_location_attributes_address_attributes_postalcode").val("");
  clinic_reset_select("clinic_clinic_locations_attributes_" + locationIndex + "_location_opened");
  $("#clinic_clinic_locations_attributes_" + locationIndex + "_sector_mask_4").prop('checked', true);
  $("#clinic_clinic_locations_attributes_" + locationIndex + "_wheelchair_accessible_mask_3").prop('checked', true);
}

function clinic_reset_select(id)
{
  // remove "selected"
  $("[id=" + id + "] option[selected='selected']").each(function() { $(this).removeAttr('selected'); });
  $("[id=" + id + "] option:first").attr('selected','selected')
  $("#" + id).trigger('liszt:updated');
}

function clinic_reset_standalone(locationIndex)
{
  clinic_reset_select("clinic_clinic_locations_attributes_" + locationIndex + "_location_attributes_address_attributes_city_id");
}

function clinic_reset_hospital(locationIndex)
{
  clinic_reset_select("clinic_clinic_locations_attributes_" + locationIndex + "_location_attributes_hospital_in_id");
}
