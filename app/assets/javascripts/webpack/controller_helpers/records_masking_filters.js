import { matchedRoute, recordShownByRoute }
  from "controller_helpers/routing";
import referralCityIds from "controller_helpers/referral_city_ids";
import { scopedByRouteAndTab } from "controller_helpers/collection_shown";
import { memoizePerRender } from "utils";
import matchesPreliminaryFilters from "controller_helpers/matches_preliminary_filters";

const recordsMaskingFilters = ((model) => {
  if (matchedRoute === "/specialties/:id" &&
    recordShownByRoute(model).maskFiltersByReferralArea){

    return scopedByRouteAndTab(model).
      filter((record) => {
        return matchesPreliminaryFilters(record, model);
      }).filter((record) => {
        return _.intersection(record.cityIds, referralCityIds(model)).
          pwPipe(_.some);
      })
  }
  else {
    return scopedByRouteAndTab(model).filter((record) => {
      return matchesPreliminaryFilters(record, model)
    });
  }
}).pwPipe(memoizePerRender);

export default recordsMaskingFilters;
