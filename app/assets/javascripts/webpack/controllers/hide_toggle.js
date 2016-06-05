import React from "react";
import { buttonIsh } from "stylesets";
import { toggleUpdateVisibility } from "action_creators";

const HideToggle = ({update, model, dispatch}) => {
  if (model.ui.persistentConfig.canHide && !update.manual) {
    return(
      <a onClick={_.partial(toggleUpdateVisibility, dispatch, update)}
        style={buttonIsh}
        className="latest_updates__toggle"
      >
        <i className={icon(update)} style={{marginRight: "5px"}}/>
        <span>{label(update)}</span>
      </a>

    )
  }
  else {
    return(<noscript/>);
  }
}

const icon = (update) => {
  if (update.hidden) {
    return "icon-check";
  }
  else {
    return "icon-remove";
  }
};

const label = (update) => {
  if (update.hidden){
    return "Show";
  }
  else {
    return "Hide";
  }
};

export default HideToggle;
