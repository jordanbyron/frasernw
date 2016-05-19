import React from "react";
import * as FilterValues from "controller_helpers/filter_values";
import _ from "lodash";
import { changeFilter } from "action_creators";
import CheckBox from "component_helpers/check_box";
import { selectedTabKey } from "controller_helpers/tab_keys";

const FilterCheckbox = ({model, dispatch, filterKey, label, filterSubkey}) => {
  return(
    <CheckBox
      label={label}
      checked={FilterValues[filterKey](model, filterSubkey)}
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

export default FilterCheckbox;
