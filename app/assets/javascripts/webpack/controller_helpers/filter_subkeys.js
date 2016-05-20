import { collectionShownName } from "controller_helpers/collection_shown";
import { matchedRoute, recordShownByPage, matchedRouteParams }
  from "controller_helpers/routing";
import referralCityIds from "controller_helpers/referral_city_ids";
import { scopedByRouteAndTab } from "controller_helpers/collection_shown";
import { memoize } from "utils";

export const scheduleDays = (model) => {
  switch(collectionShownName(model)){
  case "specialists":
    return [6, 7];
  case "clinics":
    return [1, 2, 3, 4, 5, 6, 7];
  }
};

export const careProviders = (model) => {
  return recordsMaskingFilters(model)
    .map(_.property("careProviderIds"))
    .pwPipe(_.flatten)
    .pwPipe(_.uniq);
};

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


const maskingRecordsProcedureIds = memoize(
  recordsMaskingFilters,
  (recordsMaskingFilters) => {
    return recordsMaskingFilters.
      map(_.property("procedureIds")).
      pwPipe(_.flatten).
      pwPipe(_.uniq);
  }
);

export const procedures = memoize(
  matchedRoute,
  (model) => model.app.procedures,
  recordShownByPage,
  collectionShownName,
  maskingRecordsProcedureIds,
  (matchedRoute, procedures, recordShownByPage, collectionShownName, maskingRecordsProcedureIds) => {
    if (matchedRoute === "/specialties/:id"){
      return _.values(procedures).filter((procedure) => {
        return _.includes(procedure.specializationIds, recordShownByPage.id) &&
          !_.includes(procedure.assumedSpecializationIds[collectionShownName], recordShownByPage.id) &&
          _.includes(maskingRecordsProcedureIds, procedure.id);
      }).map(_.property("id"));
    }
    else if (matchedRoute === "/areas_of_practice/:id"){
      return recordShownByPage.childrenProcedureIds;
    }
  }
);
