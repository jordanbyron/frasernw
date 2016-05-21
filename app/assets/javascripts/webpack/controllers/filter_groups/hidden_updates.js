import React from "react";
import FilterGroup from "controllers/filter_group";
import FilterCheckbox from "controllers/filter_checkbox";
import { matchedRoute } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";

const HiddenUpdatesFilter = ({model, dispatch}) => {
  if (shouldShow(model)){
    return(
      <FilterGroup
        title={"Hidden Updates"}
        isCollapsible={false}
      >
        <FilterCheckbox
          label={"Show updates that are hidden from users"}
          filterKey="showHiddenUpdates"
          model={model}
          dispatch={dispatch}
        />
      </FilterGroup>
    );
  }
  else {
    return <span></span>;
  }
}


const shouldShow = (model) => {
  return matchedRoute(model) === "/latest_updates" &&
    model.ui.canHide
}

export default HiddenUpdatesFilter;
