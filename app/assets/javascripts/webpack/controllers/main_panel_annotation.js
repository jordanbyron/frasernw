import React from "react";
import _ from "lodash";
import { route, recordShownByRoute } from "controller_helpers/routing";
import { selectedTabKey } from "controller_helpers/nav_tab_keys";
import { collectionShownPluralLabel } from "controller_helpers/collection_shown";

const MainPanelAnnotation = ({model}) => {
  if (shouldDisplay(model)) {
    return (
      <div style={{color: "#999", marginTop: "10px"}}>
        <span>
          <i className="icon-asterisk icon-disabled icon-small"
            style={{marginRight: "5px"}}
          />
          {
            (
              "Areas of practice we assume all " +
              collectionShownPluralLabel(model) +
              " see or do: " +
              recordShownByRoute(model).assumedList.join(", ")
            )
          }
        </span>
      </div>
    );
  }
  else {
    return <noscript/>
  }
};

const shouldDisplay = (model) => {
  return ((route === "/specialties/:id") &&
      _.includes(["specialists", "clinics"], selectedTabKey(model)) &&
      recordShownByRoute(model).assumedList.length > 0);
}

export default MainPanelAnnotation;
