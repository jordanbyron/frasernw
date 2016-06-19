import React from "react";
import SpecialistIconKey from "controllers/specialist_icon_key";
import ClinicIconKey from "controllers/clinic_icon_key";
import EntityPageViewsKey from "controllers/entity_page_views_key";

const SidebarAnnotation = ({model, dispatch}) => {
  return(
    <div>
      <SpecialistIconKey model={model}/>
      <ClinicIconKey model={model}/>
      <EntityPageViewsKey model={model}/>
    </div>
  )
};


export default SidebarAnnotation;
