import React from "react";
import { collectionShownName } from "controller_helpers/collection_shown";
import { route } from "controller_helpers/routing";

const ReferralIconKey = ({model}) => {
  if(shouldDisplay(model)){
    return(
      <div id="icon_key">
        <div className="title">Icon Key</div>
        <ul className="no-marker">
          {
            _.keys(model.app.referralIcons).map((key) => {
              return(
                <li>
                  <i className={model.app.referralIcons[key]}/>
                  <span>{model.app.referralTooltips[key]}</span>
                </li>
              )
            })
          }
          <li>
            <i className="icon-link"/>
            <span>Wait times provided are specific to this area of practice</span>
          </li>
        </ul>
      </div>
    );
  }
  else {
    return <noscript/>
  }
}

const ROUTES = [
  "/specialties/:id",
  "/areas_of_practice/:id",
  "/hospitals/:id",
  "/languages/:id"
];

const shouldDisplay = (model) => {
  return _.includes(ROUTES, route) &&
    _.includes(["specialists", "clincis"], collectionShownName(model))
}

export default ReferralIconKey;
