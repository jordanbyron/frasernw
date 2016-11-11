import recordsMaskingFilters from "controller_helpers/records_masking_filters";
import { route, recordShownByRoute } from "controller_helpers/routing";
import { memoizePerRender } from "utils";
import { recordShownByTab } from "controller_helpers/nav_tab_keys";
import { collectionShownName } from "controller_helpers/collection_shown";

export const scheduleDays = ((model) => {
  switch(collectionShownName(model)){
  case "specialists":
    return [6, 7];
  case "clinics":
    return [1, 2, 3, 4, 5, 6, 7];
  default:
    return [];
  }
}).pwPipe(memoizePerRender);

export const careProviders = ((model) => {
  return recordsMaskingFilters(model)
    .map(_.property("careProviderIds"))
    .pwPipe(_.flatten)
    .pwPipe(_.uniq);
}).pwPipe(memoizePerRender);

const maskingRecordsProcedureIds = ((model) => {
  return recordsMaskingFilters(model).
    map(_.property("procedureIds")).
    pwPipe(_.flatten).
    pwPipe(_.uniq);
}).pwPipe(memoizePerRender)

export const procedures = ((model) => {
  if (route === "/specialties/:id"){
    return _.values(model.app.procedures).filter((procedure) => {

      return _.includes(procedure.specializationIds, recordShownByRoute(model).id) &&
        !_.includes(
          procedure.assumedSpecializationIds[collectionShownName(model)],
          recordShownByRoute(model).id
        ) &&
        _.includes(maskingRecordsProcedureIds(model), procedure.id);
    }).map(_.property("id"));
  }
  else if (route === "/areas_of_practice/:id"){
    return recordShownByRoute(model).childrenProcedureIds;
  }
}).pwPipe(memoizePerRender)

export const languages = ((model) => {
  return recordsMaskingFilters(model).
    map(_.property("languageIds")).
    pwPipe(_.flatten).
    pwPipe(_.uniq);
}).pwPipe(memoizePerRender);

export const cities = ((model) => {
  return _.values(model.app.cities).map(_.property("id"));
}).pwPipe(memoizePerRender);

export const subcategories = ((model) => {
  return recordsMaskingFilters(model).
    map(_.property("categoryId")).
    pwPipe(_.flatten).
    pwPipe(_.uniq).
    pwPipe((ids) => _.pull(ids, recordShownByTab(model).id))
}).pwPipe(memoizePerRender)

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
