import * as preliminaryFilters from "controller_helpers/preliminary_filters";
import _ from "lodash";
import { route, recordShownByRoute } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";
import { memoizePerRender } from "utils"

export const preliminaryFilterKeys = ((collectionName) => {
  if(_.includes(["specialists", "clinics"], collectionName)){
    return [
      "availabilityKnown",
      "notHidden",
      "unavailableForAWhile"
    ];
  }
  else if (collectionName === "contentItems") {
    return [
      "matchesUserDivisions"
    ];
  }
  else {
    return [];
  }
});


const boundPreliminaryFilters = ((model) => {
  return preliminaryFilterKeys(collectionShownName(model)).
    map((filterKey) => preliminaryFilters[filterKey])
}).pwPipe(memoizePerRender)

const matchesPreliminaryFilters = (record, model) => {
  return boundPreliminaryFilters(model).every((filter) => {
    return filter(record, model);
  })
};

export default matchesPreliminaryFilters;
