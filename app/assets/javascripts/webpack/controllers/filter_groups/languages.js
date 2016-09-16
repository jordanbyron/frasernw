import React from "react";
import FilterCheckbox from "controllers/filter_checkbox";
import FilterGroup from "controllers/filter_group";
import { route } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";
import { languages as subkeys } from "controller_helpers/filter_subkeys";

const LanguagesFilters = ({model, dispatch}) => {
  if (shouldShow(model)){
    return(
      <FilterGroup
        title={"Languages"}
        isCollapsible={true}
        expansionControlKey={"languages"}
        defaultIsExpanded={false}
        model={model}
        dispatch={dispatch}
      >
        <FilterCheckbox
          label={"Interpreter Available"}
          filterKey="interpreterAvailable"
          key="interpreterAvailable"
          model={model}
          dispatch={dispatch}
          isHalfColumn={true}
        />
        {
          subkeys(model).map((key) => {
            return(
              <FilterCheckbox
                label={model.app.languages[key].name}
                key={key}
                filterKey="languages"
                filterSubkey={key}
                model={model}
                dispatch={dispatch}
                isHalfColumn={true}
              />
            );
          }).pwPipe((boxes) => _.sortBy(boxes, _.property("props.label")))
        }
      </FilterGroup>
    );
  }
  else {
    return <span></span>;
  }
};

const shouldShow = (model) => {
  return _.includes(ROUTES, route) &&
    _.includes(COLLECTIONS, collectionShownName(model))
}
const ROUTES = [
  "/specialties/:id",
  "/areas_of_practice/:id",
  "/hospitals/:id"
];
const COLLECTIONS = [
  "specialists",
  "clinics"
];

export default LanguagesFilters;
