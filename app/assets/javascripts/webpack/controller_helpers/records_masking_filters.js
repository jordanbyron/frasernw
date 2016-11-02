import { route, recordShownByRoute } from "controller_helpers/routing";
import { selectedTabKey } from "controller_helpers/tab_keys";
import referralCityIds from "controller_helpers/referral_city_ids";
import { scopedByRouteAndTab } from "controller_helpers/collection_shown";
import { memoizePerRender } from "utils";
import matchesPreliminaryFilters from "controller_helpers/matches_preliminary_filters";

const recordsMaskingFilters = ((model) => {
  if (route === "/specialties/:id" &&
    ["clinics", "specialists"].includes(selectedTabKey(model)) &&
    recordShownByRoute(model).maskFiltersByReferralArea) {
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
