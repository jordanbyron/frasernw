import React from "react";
import * as FilterValues from "controller_helpers/filter_values";
import _ from "lodash";
import { changeFilter } from "action_creators";
import CheckBox from "component_helpers/check_box";
import { selectedTabKey } from "controller_helpers/nav_tab_keys";

const FilterCheckbox = ({
  model,
  dispatch,
  filterKey,
  label,
  filterSubkey,
  isHalfColumn,
  style
}) => {
  return(
    <CheckBox
      label={label}
      checked={FilterValues[filterKey](model, filterSubkey)}
      labelStyle={labelStyle(isHalfColumn)}
      style={style || {}}
      onChange={
        _.partial(
          changeFilter,
          dispatch,
          selectedTabKey(model),
          filterKey,
          filterSubkey
        )
      }
    />
  );
};

const labelStyle = (isHalfColumn) => {
  if (isHalfColumn){
    return {
      display: "inline-block",
      width: "90px"
    };
  }
  else {
    return {};
  }
};

export default FilterCheckbox;
