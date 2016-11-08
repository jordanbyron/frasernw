var toggleProcedureSpecializationControls = function(mappedInput) {
  var block = $(mappedInput).parents(".fields");
  var childControls = block.find(".child-controls");

  if ( $(mappedInput).is(":checked") )
  {
    childControls.show();
  }
  else
  {
    childControls.hide();
  }
}
