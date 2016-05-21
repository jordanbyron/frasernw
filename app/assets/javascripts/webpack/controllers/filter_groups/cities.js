import React from "react";
import FilterCheckbox from "controllers/filter_checkbox";
import FilterGroup from "controllers/filter_group";
import { matchedRoute } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";
import { cities as subkeys } from "controller_helpers/filter_subkeys";
import { updateCityFilters } from "action_creators";
import referralCityIds from "controller_helpers/referral_city_ids";

const CityFilters = ({model, dispatch}) => {
  if (shouldShow(model)){
    return(
      <FilterGroup
        title={"Cities"}
        isCollapsible={true}
        expansionControlKey={"cities"}
        defaultIsExpanded={false}
        model={model}
        dispatch={dispatch}
      >
        <div style={{color: "#CEC9C9"}}>
          <a style={{cursor: "pointer"}}
            onClick={
              _.partial(
                updateCityFilters,
                dispatch,
                model,
                subkeys(model)
              )
            }
          >
            All Cities
          </a>
          <span style={{marginLeft: "3px", marginRight: "3px"}}>|</span>
          <a style={{cursor: "pointer"}}
            onClick={
              _.partial(
                updateCityFilters,
                dispatch,
                model,
                referralCityIds(model)
              )
            }
          >
            Regional Cities
          </a>
          <span style={{marginLeft: "3px", marginRight: "3px"}}>|</span>
          <a style={{cursor: "pointer"}}
          onClick={
              _.partial(
                updateCityFilters,
                dispatch,
                model,
                []
              )
            }
          >
            No Cities
          </a>
        </div>
        <hr
          style={{
            margin: "0px",
            borderColor: "#CEC9C9",
            marginBottom: "6px",
            marginTop: "4px",
            borderWidth: "1px"
          }}
        />
        {
          subkeys(model).map((key) => {
            return(
              <FilterCheckbox
                label={model.app.cities[key].name}
                key={key}
                filterKey="cities"
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
  return _.includes(ROUTES, matchedRoute(model)) &&
    _.includes(COLLECTIONS, collectionShownName(model))
}
const ROUTES = [
  "/specialties/:id",
  "/areas_of_practice/:id"
];
const COLLECTIONS = [
  "specialists",
  "clinics"
];

export default CityFilters;
