import React from "react";
import _ from "lodash";
import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import { collectionShownPluralLabel } from "controller_helpers/collection_shown";
import * as filterValues from "controller_helpers/filter_values";


const GreyAnnotation = ({model}) => {
  if (shouldDisplay(model)) {
    return (
      <div style={{color: "#999", marginTop: "10px"}}>
        { label(model) }
      </div>
    );
  }
  else {

  }
}

const shouldDisplay = (model) => {
  return matchedRoute(model) === "/reports/entity_page_views" ||
    ((matchedRoute(model) === "/specialties/:id") &&
      recordShownByPage(model).assumedList.length > 0)
}

const label = (model) => {
  switch(matchedRoute(model)){
  case "/reports/entity_page_views":
    switch(filterValues.entityType(model)){
    case "forms":
      var dynamic = "'Page Views' are defined as views of the uploaded form.";
    case "specialties":
      var dynamic = "'Page Views' are defined as views at '/specialties/<id>.'";
    case "clinics":
      var dynamic = "'Page Views' are defined as views at '/clinics/<id>.'";
    case "specialists":
      var dynamic = "'Page Views' are defined as views at '/specialists/<id>.'";
    default:
      var dynamic = `
      'Page Views' are defined as views of the page at the url that is linked to on user-facing tables
      (i.e. specialization pages).
      Depending on the format of the resource, this may be an external page or a page on Pathways ('/content_items/<id>').
      `
    }

    return `${dynamic} Views by admins are excluded.`;
  case "/specialties/:id":
    return(
      <span>
        <i className="icon-asterisk icon-disabled icon-small"
          style={{marginRight: "5px"}}
        />
        {
          (
            "Areas of practice we assume all " +
            collectionShownPluralLabel(model) +
            " see or do: " +
            recordShownByPage(model).assumedList.join(", ")
          )
        }
      </span>
    )
  }
};


export default GreyAnnotation;
