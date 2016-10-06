export default function updateSpecialistLocation(){
  const locationIsKey = $(`input:checked[name='${this.name}']`)[0].
    value.
    pwPipe(parseInt)

  const locationIndex = this.getAttribute("data-location-index");

  if (locationIsKey === 0) {
    $('.numbers_' + locationIndex).hide();
    $('.office_' + locationIndex).hide();
    $('.address_' + locationIndex).hide();
    $('.hospital_' + locationIndex).hide();
    $('.clinic_' + locationIndex).hide();
    $('.details_' + locationIndex).hide();
    $('.universal_' + locationIndex).hide();
    resetOffice(locationIndex);
    resetHospital(locationIndex);
    resetClinic(locationIndex);
    resetNumbers(locationIndex);
  }
  else if (locationIsKey === 2){
    $('.numbers_' + locationIndex).show();
    $('.office_' + locationIndex).hide();
    $('.address_' + locationIndex).show();
    $('.hospital_' + locationIndex).hide();
    $('.clinic_' + locationIndex).hide();
    $('.details_' + locationIndex).hide();
    $('.universal_' + locationIndex).show();
    resetHospital(locationIndex);
    resetClinic(locationIndex);
  }
  else if (locationIsKey === 1 || locationIsKey === 5){
    $('.numbers_' + locationIndex).show();
    $('.office_' + locationIndex).show();
    $('.address_' + locationIndex).hide();
    $('.hospital_' + locationIndex).hide();
    $('.clinic_' + locationIndex).hide();
    $('.details_' + locationIndex).hide();
    $('.universal_' + locationIndex).show();
    resetHospital(locationIndex);
    resetClinic(locationIndex);
  }
  else if (locationIsKey === 3){
    $('.numbers_' + locationIndex).show();
    $('.office_' + locationIndex).hide();
    $('.address_' + locationIndex).hide();
    $('.hospital_' + locationIndex).show();
    $('.clinic_' + locationIndex).hide();
    $('.details_' + locationIndex).show();
    $('.universal_' + locationIndex).show();
    resetOffice(locationIndex);
    resetClinic(locationIndex);
  }
  else if (locationIsKey === 4){
    $('.numbers_' + locationIndex).show();
    $('.office_' + locationIndex).hide();
    $('.address_' + locationIndex).hide();
    $('.hospital_' + locationIndex).hide();
    $('.clinic_' + locationIndex).show();
    $('.details_' + locationIndex).show();
    $('.universal_' + locationIndex).show();
    resetOffice(locationIndex);
    resetHospital(locationIndex);
  }
}


function resetNumbers(locationIndex)
{
  $("#specialist_specialist_offices_attributes_" + locationIndex + "_phone").val("");
  $("#specialist_specialist_offices_attributes_" + locationIndex + "_phone_extension").val("");
  $("#specialist_specialist_offices_attributes_" + locationIndex + "_fax").val("");
  $("#specialist_specialist_offices_attributes_" + locationIndex + "_direct_phone").val("");
  $("#specialist_specialist_offices_attributes_" + locationIndex + "_direct_phone_extension").val("");
  $("#specialist_specialist_offices_attributes_" + locationIndex + "_email").val("");
  $("#specialist_specialist_offices_attributes_" + locationIndex + "_url").val("");
  resetSelect("specialist_specialist_offices_attributes_" + locationIndex + "_location_opened");
  $("#specialist_specialist_offices_attributes_" + locationIndex + "_sector_mask_4").prop('checked', true);
}

function resetSelect(id)
{
  // remove "selected"
  $("[id=" + id + "] option[selected='selected']").each(function() { $(this).removeAttr('selected'); });
  $("[id=" + id + "] option:first").attr('selected','selected');
  $("#" + id).trigger('liszt:updated');
}

function resetOffice(locationIndex)
{
  resetSelect("specialist_specialist_offices_attributes_" + locationIndex + "_office_id");
}

function resetHospital(locationIndex)
{
  //specialist edit page
  resetSelect("specialist_specialist_offices_attributes_" + locationIndex + "_office_attributes_location_attributes_hospital_in_id");

  //offices edit
  resetSelect("office_location_attributes_location_in_id");
  resetSelect("office_location_attributes_hospital_in_id");
}

function resetClinic(locationIndex)
{
  resetSelect("specialist_specialist_offices_attributes_" + locationIndex + "_office_attributes_location_attributes_location_in_id");
}
