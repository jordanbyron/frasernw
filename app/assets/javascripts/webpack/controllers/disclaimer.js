import React from "react";
import isDataDubious from "controller_helpers/dubious_data";
import * as filterValues from "controller_helpers/filter_values";
import _ from "lodash";

const Disclaimer = ({model}) => {
  if(isDataDubious(model)) {
    return(
      <div
        className="alert alert-info"
        style={{marginTop: "10px"}}
      > { label(model) }
      </div>
    );
  }
  else {
    return <noscript/>
  }
};

const label = (model) => {
  if(model.app.currentUser.role === "super"){
    return(
      "Please note that this data (pre- November 2015) can only be relied on to count clicks " +
      "on links to resources which are hosted ON PATHWAYS as inline content.  " +
      "It's highly suggested that this data is not used for decisionmaking."
    );
  }
  else {
    return(
      _.startCase(filterValues.entityType(model)) +
      " page views are only available for November 2015 and later."
    );
  }
}

export default Disclaimer;
