import React from "react";
import {
  divisionScope as divisionScopeValue,
  entityType as entityTypeValue
} from "controller_helpers/filter_values";
import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import { toSentence } from "utils";

const PageTitle = ({model, dispatch}) => {
  if (label(model)) {
    return(
      <h2 style={{marginBottom: "10px"}}>
        { label(model) }
      </h2>
    );
  }
  else {
    return <span></span>
  }
};

const label = (model) => {
  switch(matchedRoute(model)){
  case "/reports/pageviews_by_user":
    return "Page Views by User";
  case "/content_categories/:id":
    let parentContentCategory =
      model.app.contentCategories[recordShownByPage(model).ancestry];

    if (parentContentCategory){
      return `${parentContentCategory.name}: ${recordShownByPage(model).name}`;
    }
    else {
      return recordShownByPage.name;
    }
  case "/reports/referents_by_specialty":
    if (parseInt(divisionScopeValue(model)) === 0) {
      var scope = "Pathways";
    } else {
      var scope = model.app.divisions[divisionScopeValue(model)].name;
    }

    return `${scope} ${_.capitalize(entityTypeValue(model))} (${"TODO"} total)`;
  case "/latest_updates":
    let divisionNames = model.ui.divisionIds.map((id) => {
      return model.app.divisions[id].name;
    });

    return `Latest Specialist and Clinic Updates for ${toSentence(divisionNames)}`;
  case "/reports/usage":
    if (parseInt(divisionScopeValue(model)) === 0) {
      var scopeLabel = "by Page Views";
    }
    else {
      var scopeLabel = "by " +
        model.app.divisions[divisionScopeValue(model)].name +
        " Users' Page Views"
    }

    return (
      "Top " +
      _.startCase(entityTypeValue(model)) +
      " " +
      scopeLabel
    );
  }
}

export default PageTitle;
