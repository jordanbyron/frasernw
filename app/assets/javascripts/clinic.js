var hideShowPhysicians = function() 
{
  if ( $(this).is(":checked") )
  {
    //we have indicated a specialist
    $(this).siblings(".specialist_list").show();
    $(this).siblings(".freeform").hide();
  }
  else
  {
    //we have indicated a freeform answer
    $(this).siblings(".specialist_list").hide();
    $(this).siblings(".freeform").show();
  }
}

$(".is_specialist").live("change", hideShowPhysicians );