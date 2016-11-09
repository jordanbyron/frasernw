import React from "react";
import ExpandableFilterGroup from "component_helpers/expandable_filter_group";
import FilterGroup from "component_helpers/filter_group";
import { toggleFilterGroupExpansion } from "action_creators";
import { selectedTabKey } from "controller_helpers/nav_tab_keys";

const FilterGroupController = ({
  model,
  dispatch,
  title,
  isCollapsible,
  expansionControlKey,
  defaultIsExpanded,
  children
}) => {
  if (isCollapsible){
    return(
      <ExpandableFilterGroup
        title={title}
        isCollapsible={isCollapsible}
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
      </ExpandableFilterGroup>
    );
  }
  else {
    return(
      <FilterGroup title={title}>
        {children}
      </FilterGroup>
    )
  }
};

const isExpanded = (model, defaultIsExpanded, expansionControlKey) => {
  return _.get(
    model,
    ["ui", "tabs", selectedTabKey(model), "isFilterGroupExpanded", expansionControlKey],
    defaultIsExpanded
  )
};

export default FilterGroupController;
