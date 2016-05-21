import React from "react";
import FilterCheckbox from "controllers/filter_checkbox";
import ExpandingContainer from "component_helpers/expanding_container";
import * as FilterValues from "controller_helpers/filter_values";

const NestedFilterCheckbox = ({
  model,
  dispatch,
  filterKey,
  label,
  filterSubkey,
  level,
  children
}) => {
  return(
    <div>
      <FilterCheckbox
        model={model}
        dispatch={dispatch}
        filterKey={filterKey}
        label={label}
        filterSubkey={filterSubkey}
        style={{marginLeft: ((level * 20).toString() + "px")}}
      />
      <ExpandingContainer expanded={FilterValues[filterKey](model, filterSubkey)}>
        { children }
      </ExpandingContainer>
    </div>
  )
}

export default NestedFilterCheckbox;
