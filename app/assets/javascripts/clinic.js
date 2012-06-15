var hideShowPhysicians = function() 
{
  var currentId = $(this).attr('id');
  
  var specialists = "#" + currentId.replace("is_specialist","specialist_id");
  var firstname = "#" + currentId.replace("is_specialist","freeform_firstname");
  var lastname = "#" + currentId.replace("is_specialist","freeform_lastname");
  
  if ( $(this).is(":checked") )
  {
    //we have indicated a specialist
    $(specialists).show();
    $(firstname).hide();
    $(lastname).hide();
  }
  else
  {
    //we have indicated a freeform answer
    $(specialists).hide();
    $(firstname).show();
    $(lastname).show();
  }
}

$(".is_specialist").live("change", hideShowPhysicians );

var clinic_categorization_changed = function()
{
  if ($(this).val() == 1 || $(this).val() == 2)
  {
    //surveyed (may or may not have fully responded)
    $("#section_contact").show();
    $("#section_moa").show();
    $("#section_status").show();
    $("#section_aop").show();
    $("#section_referrals").show();
    $("#section_for_patients").show();
    $("#section_associations").show();
    $("#section_healthcare_providers").show();
    $("#section_admin").show();
    $("#section_deprecated").show();
  }
  else
  {
    //purposely not surveyed
    //in this case we will show their associations but nothing else, as all the rest is personal to them 
    $("#section_contact").hide();
    $("#section_moa").hide();
    $("#section_status").hide();
    $("#section_aop").hide();
    $("#section_referrals").hide();
    $("#section_for_patients").hide();
    $("#section_associations").show();
    $("#section_healthcare_providers").hide();
    $("#section_admin").show();
    $("#section_deprecated").show();
  }
}

$("#clinic_categorization_mask").live("change", clinic_categorization_changed)
