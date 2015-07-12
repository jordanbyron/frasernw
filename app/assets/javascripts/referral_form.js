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

var initReferralForms = function()
{
  if ( $(this).val() != 1 )
  {
    return;
  }

  $(this).is(":checked") ? $("#referral_forms").show() : $("#referral_forms").hide();
}
