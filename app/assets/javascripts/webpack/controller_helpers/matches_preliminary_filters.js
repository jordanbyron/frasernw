import * as preliminaryFilters from "controller_helpers/preliminary_filters";
import _ from "lodash";
import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";
import { memoizePerRender } from "utils"

export const preliminaryFilterKeys = ((model) => {
  if(_.includes(["/specialties/:id", "/areas_of_practice/:id"], matchedRoute(model))&&
  _.includes(["specialists", "clinics"], collectionShownName(model))){

    return [
      "status",
      "showInTable"
    ];
  }
  else {
    return [];
  }
}).pwPipe(memoizePerRender);

const boundPreliminaryFilters = ((model) => {
  return preliminaryFilterKeys(model).
    map((filterKey) => preliminaryFilters[filterKey])
}).pwPipe(memoizePerRender)

const matchesPreliminaryFilters = (record, model) => {
  return boundPreliminaryFilters(model).every((filter) => {
    return filter(record);
  })
};

export default matchesPreliminaryFilters;
