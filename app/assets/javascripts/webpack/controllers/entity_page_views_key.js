import React from "react";
import * as filterValues from "controller_helpers/filter_values";
import { route } from "controller_helpers/routing";

const EntityPageViewsKey = ({model, dispatch}) => {
  if (route === "/reports/entity_page_views"){
    return(
      <div style={{color: "#999", marginTop: "10px"}}>
        { `${dynamic(model)} Views by admins are excluded.` }
      </div>
    )
  }
  else {
    return <noscript/>
  }
}

const dynamic = (model) => {
  switch(filterValues.entityType(model)){
  case "forms":
    return "'Page Views' are defined as views of the uploaded form.";
  case "specialties":
    return "'Page Views' are defined as views at '/specialties/<id>.'";
  case "clinics":
    return "'Page Views' are defined as views at '/clinics/<id>.'";
  case "contentCategories":
    return "'Page Views' are defined as views at '/content_categories/<id>.'";
  case "specialists":
    return "'Page Views' are defined as views at '/specialists/<id>.'";
  default:
    return `
    'Page Views' are defined as views of the page at the url that is linked to on user-facing tables
    (i.e. specialization pages).
    Depending on the format of the resource, this may be an external page or a page on Pathways ('/content_items/<id>').
    `
  }
}

export default EntityPageViewsKey;
