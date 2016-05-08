var toggleProcedureMappings = function(target)
{
  var row = $(target).parents(".procedure_specialization_row");


  var parentId = row.find(".input--parent_id");
  var classification = row.find(".input--classification");
  var clinicWaittime = row.find(".input--clinic_wait_time");
  var specialistWaittime = row.find(".input--specialist_wait_time");

  if ( $(target).is(":checked") )
  {
    parentId.show();
    classification.show();
    clinicWaittime.show();
    specialistWaittime.show();
  }
  else
  {
    //we have indicated that this area of practice does not belong to this specialization, so hide parents and type
    parentId.hide();
    classification.hide();
    clinicWaittime.hide();
    specialistWaittime.hide();
  }
}
