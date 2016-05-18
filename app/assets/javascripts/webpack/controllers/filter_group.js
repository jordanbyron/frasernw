import React from "react";
import FilterGroup from "component_helpers/filter_group";
import { toggleFilterGroupExpansion } from "action_creators";
import { selectedTabKey } from "controller_helpers/tab_keys";

const FilterGroupController = ({
  model,
  dispatch,
  title,
  isExpandable,
  expansionControlKey,
  defaultIsExpanded,
  children
}) => {
  return(
    <FilterGroup
      title={title}
      isExpandable={isExpandable}
      isExpanded={isExpanded(model, defaultIsExpanded, expansionControlKey)}
      toggleExpansion={
        _.partial(
          toggleFilterGroupExpansion,
          dispatch,
          selectedTabKey(model),
          expansionControlKey,
          !isExpanded(model, defaultIsExpanded, expansionControlKey)
        )
      }
    >
      { children }
    </FilterGroup>
  );
};

const isExpanded = (model, defaultIsExpanded, expansionControlKey) => {
  return _.get(
    model,
    ["ui", "tabs", selectedTabKey(model), "isFilterGroupExpanded", expansionControlKey],
    defaultIsExpanded
  )
};

export default FilterGroupController;
