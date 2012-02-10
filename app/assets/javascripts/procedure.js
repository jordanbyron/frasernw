var hideShowParents = function() 
{
  var currentId = $(this).attr('id');
  var select = "#" + currentId.replace("check","select");
  
  if ( $(this).is(":checked") )
  {
    //we have indicated that this area of practice belongs to this specializatios, so let us pick a parent
    $(select).show();
  }
  else
  {
    //we have indicated that this area of practice does not belong to this specialization, so hide parents 
    $(select).hide();
  }
}

$(".aop_active").live("change", hideShowParents );