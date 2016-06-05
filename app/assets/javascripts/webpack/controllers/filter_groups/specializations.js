import React from "react";
import FilterCheckbox from "controllers/filter_checkbox";
import FilterGroup from "controllers/filter_group";
import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import recordsMaskingFilters from "controller_helpers/records_masking_filters";
import FilterRadioButtons from "controllers/filter_radio_buttons";

const SpecializationsFilters = ({model, dispatch}) => {
  if (matchedRoute(model) === "/content_categories/:id" ||
    matchedRoute(model) === "/hospitals/:id" ||
    matchedRoute(model) === "/languages/:id") {
      
    return(
      <FilterGroup
        title={"Specialties"}
        isCollapsible={true}
        expansionControlKey={"specializations"}
        defaultIsExpanded={true}
        model={model}
        dispatch={dispatch}
      >
        <FilterRadioButtons
          filterKey="specializations"
          options={radioOptions(model)}
          model={model}
          dispatch={dispatch}
        />
      </FilterGroup>
    );
  }
  else {
    return <span></span>;
  }
};

const radioOptions = (model) => {
  return recordsMaskingFilters(model).
    map(_.property("specializationIds")).
    pwPipe(_.flatten).
    pwPipe(_.uniq).
    map((id) => {
      return { key: id, label: model.app.specializations[id].name };
    }).pwPipe((options) => _.sortBy(options, _.property("label"))).
    pwPipe((options) => [{key: 0, label: "All"}].concat(options))
}

export default SpecializationsFilters;
