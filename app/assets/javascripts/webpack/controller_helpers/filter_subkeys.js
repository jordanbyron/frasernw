import recordsMaskingFilters from "controller_helpers/records_masking_filters";
import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import { memoize } from "utils";
import { recordShownByTab } from "controller_helpers/tab_keys";
import { collectionShownName } from "controller_helpers/collection_shown";

export const scheduleDays = (model) => {
  switch(collectionShownName(model)){
  case "specialists":
    return [6, 7];
  case "clinics":
    return [1, 2, 3, 4, 5, 6, 7];
  default:
    return [];
  }
};

export const careProviders = (model) => {
  return recordsMaskingFilters(model)
    .map(_.property("careProviderIds"))
    .pwPipe(_.flatten)
    .pwPipe(_.uniq);
};

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

export const languages = memoize(
  recordsMaskingFilters,
  (recordsMaskingFilters) => {
    return recordsMaskingFilters.
      map(_.property("languageIds")).
      pwPipe(_.flatten).
      pwPipe(_.uniq);
  }
);

export const cities = memoize(
  (model) => model.app.cities,
  (cities) => {
    return _.values(cities).map(_.property("id"));
  }
);

export const subcategories = memoize(
  recordsMaskingFilters,
  recordShownByTab,
  (recordsMaskingFilters, recordShownByTab) => {
    return recordsMaskingFilters.
      map(_.property("categoryId")).
      pwPipe(_.flatten).
      pwPipe(_.uniq).
      pwPipe((ids) => _.pull(ids, recordShownByTab.id))
  }
)

export const sex = () => {
  return [
    "male",
    "female"
  ];
};

export const teleserviceRecipients = () => {
  return [
    "provider",
    "patient"
  ];
}

export const teleserviceFeeTypes = () => {
  return [1, 2, 3, 4];
}
