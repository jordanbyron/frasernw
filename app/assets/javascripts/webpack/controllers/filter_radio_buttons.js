import React from "react";
import * as FilterValues from "controller_helpers/filter_values";
import _ from "lodash";
import { changeFilter } from "action_creators";
import RadioButtons from "component_helpers/radio_buttons";
import { selectedTabKey } from "controller_helpers/nav_tab_keys";

const FilterRadioButtons = ({model, dispatch, filterKey, options}) => {
  return(
    <RadioButtons
      value={FilterValues[filterKey](model)}
      options={options}
      name={filterKey}
      onChange={
        _.partial(
          changeFilter,
          dispatch,
          selectedTabKey(model),
          filterKey,
          null
        )
      }
    />
  );
};

export default FilterRadioButtons;
