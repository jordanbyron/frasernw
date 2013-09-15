function office_reset_select(id)
{
  // remove "selected"
  $("[id=" + id + "] option[selected='selected']").each(function() { $(this).removeAttr('selected'); });
  $("[id=" + id + "] option:first").attr('selected','selected');
}

function office_reset_hospital()
{
  reset_select("office_location_attributes_location_in_id");
  reset_select("office_location_attributes_hospital_in_id");
}

function office_reset_clinic()
{
  reset_select("office_location_attributes_clinic_in_id")
}

var office_address_location_changed = function()
{
  if ($('#office_location_Not_used').is(':checked'))
  {
    $('.numbers').hide();
    $('.office').hide();
    $('.address').hide();
    $('.hospital').hide();
    $('.clinic').hide();
    $('.details').hide();
    $('.universal').hide();
    office_reset_office();
    office_reset_hospital();
    office_reset_clinic();
  }
  else if ($('#office_location_Standalone').is(':checked'))
  {
    $('.numbers').show();
    $('.office').hide();
    $('.address').show();
    $('.hospital').hide();
    $('.clinic').hide();
    $('.details').hide();
    $('.universal').show();
    office_reset_hospital();
    office_reset_clinic();
  }
  else if ($('#office_location_In_a_hospital').is(':checked'))
  {
    $('.numbers').show();
    $('.office').hide();
    $('.address').hide();
    $('.hospital').show();
    $('.clinic').hide();
    $('.details').show();
    $('.universal').show();
    office_reset_clinic();
  }
  else if ($('#office_location_In_a_clinic').is(':checked'))
  {
    $('.numbers').show();
    $('.office').hide();
    $('.address').hide();
    $('.hospital').hide();
    $('.clinic').show();
    $('.details').show();
    $('.universal').show();
    office_reset_hospital();
  }
}

$(".office_location").live("change", office_address_location_changed);