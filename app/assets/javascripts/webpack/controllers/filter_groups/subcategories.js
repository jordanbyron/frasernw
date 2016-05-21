import React from "react";
import FilterCheckbox from "controllers/filter_checkbox";
import FilterGroup from "controllers/filter_group";
import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import recordsMaskingFilters from "controller_helpers/records_masking_filters";
import { collectionShownName } from "controller_helpers/collection_shown";
import { subcategories as subkeys } from "controller_helpers/filter_subkeys";
import FilterRadioButtons from "controllers/filter_radio_buttons";

const SubcategoriesFilters = ({model, dispatch}) => {
  if (_.includes(CHECKBOX_ROUTES, matchedRoute(model)) &&
    _.includes(COLLECTIONS, collectionShownName(model))){
      return(
        <FilterGroup
          title={"Subcategories"}
          isCollapsible={true}
          expansionControlKey={"subcategories"}
          defaultIsExpanded={true}
          model={model}
          dispatch={dispatch}
        >
          {
            subkeys(model).map((key) => {
              return(
                <FilterCheckbox
                  label={model.app.contentCategories[key].name}
                  key={key}
                  filterKey="subcategories"
                  filterSubkey={key}
                  model={model}
                  dispatch={dispatch}
                />
              );
            }).pwPipe((boxes) => _.sortBy(boxes, _.property("props.label")))
          }
        </FilterGroup>
      );
  }
  else if (matchedRoute(model) === "/content_categories/:id") {
    return(
      <FilterGroup
        title={"Subcategories"}
        isCollapsible={true}
        expansionControlKey={"subcategories"}
        defaultIsExpanded={true}
        model={model}
        dispatch={dispatch}
      >
        <FilterRadioButtons
          filterKey="subcategories"
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
    map(_.property("categoryId")).
    pwPipe(_.flatten).
    pwPipe(_.uniq).
    pwPipe((ids) => _.pull(ids, recordShownByPage.id)).
    map((id) => {
      return { key: id, label: model.app.contentCategories[id].name };
    }).pwPipe((options) => _.sortBy(options, _.property("label"))).
    pwPipe((options) => [{key: 0, label: "All"}].concat(options))
}

const CHECKBOX_ROUTES = [
  "/specialties/:id",
  "/areas_of_practice/:id"
];
const COLLECTIONS = [
  "contentItems"
];

export default SubcategoriesFilters;
