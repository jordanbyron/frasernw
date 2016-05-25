import React from "react";
import { month as monthValue } from "controller_helpers/filter_values";
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
  case "/reports/usage":
    return labelMonthOption(monthValue(model));
  }
}

export default Subtitle;
