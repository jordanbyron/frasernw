import React from "react";
import * as FilterValues from "controller_helpers/filter_values";
import _ from "lodash";
import { changeFilter } from "action_creators";
import Selector from "component_helpers/selector";
import { selectedTabKey } from "controller_helpers/nav_tab_keys";

const FilterSelector = ({model, dispatch, filterKey, label, filterSubkey, options}) => {
  return(
    <Selector
      label={label}
      value={FilterValues[filterKey](model, filterSubkey)}
      options={options}
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

export default FilterSelector;
