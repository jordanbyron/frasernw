import React from "react";
import { collectionShownName } from "controller_helpers/collection_shown";

const SpecialistIconKey = ({model}) => {
  if(collectionShownName(model) === "specialists"){
    return(
      <div id="icon_key">
        <div className="title">Icon Key</div>
        <ul className="no-marker">
          <li>
            <i className="icon-ok icon-green"/>
            <span>Accepting New referrals</span>
          </li>
          <li>
            <i className="icon-ok icon-orange"/>
            <span>Accepting limited new referrals by geography or # of patients</span>
          </li>
          <li>
            <i className="icon-remove icon-red"/>
            <span>Not accepting new referrals</span>
          </li>
          <li>
            <i className="icon-signout icon-blue"/>
            <span>Only works out of, and possibly accepts referrals through, clinics and/or hospitals</span>
          </li>
          <li>
            <i className="icon-warning-sign icon-orange"/>
            <span>Referral status will change soon</span>
          </li>
          <li>
            <i className="icon-question-sign icon-text"/>
            <span>Referral status is unknown</span>
          </li>
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

export default SpecialistIconKey;
