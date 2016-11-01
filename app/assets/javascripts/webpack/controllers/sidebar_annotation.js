import React from "react";
import ReferralIconKey from "controllers/referral_icon_key";
import EntityPageViewsKey from "controllers/entity_page_views_key";

const SidebarAnnotation = ({model, dispatch}) => {
  return(
    <div>
      <ReferralIconKey model={model}/>
      <EntityPageViewsKey model={model}/>
    </div>
  )
};


export default SidebarAnnotation;
