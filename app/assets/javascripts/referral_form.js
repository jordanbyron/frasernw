var hideShowReferralForms = function() 
{
  if ( $(this).val() == 1 )
  {
    $("#referral_forms").show();
  }
  else
  {
    $("#referral_forms").hide();
  }
}

$(".referral_form_mask").live("change", hideShowReferralForms);