import { matchedRoute, recordShownByPage }
  from "controller_helpers/routing";
import referralCityIds from "controller_helpers/referral_city_ids";
import { scopedByRouteAndTab } from "controller_helpers/collection_shown";
import { memoize } from "utils";

const recordsMaskingFilters = memoize(
  matchedRoute,
  recordShownByPage,
  scopedByRouteAndTab,
  referralCityIds,
  (matchedRoute, recordShownByPage, scopedByRouteAndTab, referralCityIds) => {
    if (matchedRoute === "/specialties/:id" &&
      recordShownByPage.maskFiltersByReferralArea){

      return scopedByRouteAndTab.filter((record) => {
        return _.intersection(record.cityIds, referralCityIds).
          pwPipe(_.some);
      })
    }
    else {
      return scopedByRouteAndTab;
    }
  }
);

export default recordsMaskingFilters;
