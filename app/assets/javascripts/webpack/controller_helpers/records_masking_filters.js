import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import referralCityIds from "controller_helpers/referral_city_ids";
import { scopedByRouteAndTab } from "controller_helpers/collection_shown";

const recordsMaskingFilters = (model) => {
  if (matchedRoute(model) === "/specialties/:id" &&
    recordShownByPage(model).maskFiltersByReferralArea){

    return scopedByRouteAndTab(model).filter((record) => {
      return _.intersection(record.cityIds, referralCityIds(model)).
        pwPipe(_.some);
    })
  }
  else {
    return scopedByRouteAndTab(model);
  }
};

export default recordsMaskingFilters;
