var hideShowParents = function() 
{
  if ( $(this).is(":checked") )
  {
    //we have indicated that this area of practice belongs to this specializatios, so let us pick a parent
    $(this).siblings(".parent").show();
  }
  else
  {
    //we have indicated that this area of practice does not belong to this specialization, so hide parents 
    $(this).siblings(".parent").hide();
  }
}

$(".aop_active").live("change", hideShowParents );