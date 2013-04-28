class ReferralFormsController < ApplicationController
  load_and_authorize_resource

  def index
    user_divisions = current_user_divisions
    @referral_forms = ReferralForm.all.reject{ |rf| rf.referrable.blank? || rf.referrable.not_available? || !rf.in_divisions(user_divisions)  }
    render :layout => 'ajax' if request.headers['X-PJAX']
  end
end
