import React from "react";
import * as filterValues from "controller_helpers/filter_values";
import { matchedRoute } from "controller_helpers/routing";
import { labelMonthOption } from "controller_helpers/month_options";

const Subtitle = ({model, dispatch}) => {
  if (label(model)) {
    return(
      <h4>
        { label(model) }
      </h4>
    );
  }
  else {
    return <span></span>
  }
};

const label = (model) => {
  switch(matchedRoute(model)){
  case "/reports/entity_page_views":
    if(filterValues.startMonth(model) === filterValues.endMonth(model)){
      return labelMonthOption(filterValues.startMonth(model))
    }
    else {
      return(
        labelMonthOption(filterValues.startMonth(model)) +
        " - " +
        labelMonthOption(filterValues.endMonth(model))
      );
    }
  }
}

export default Subtitle;
