import { route, recordShownByRoute, matchesRoute } from "controller_helpers/routing";
import { unscopedCollectionShown, collectionShownName }
  from "controller_helpers/collection_shown";
import matchesPreliminaryFilters from "controller_helpers/matches_preliminary_filters";
import matchesSidebarFilters from "controller_helpers/matches_sidebar_filters";
import { matchesSidebarFiltersExceptCities } from "controller_helpers/matches_sidebar_filters";
import activatedFilterSubkeys from "controller_helpers/activated_filter_subkeys";
import { selectedTabKey } from "controller_helpers/nav_tab_keys";
import { memoizePerRender } from "utils";
import { recordShownByBreadcrumb } from "controller_helpers/breadcrumbs";

export const showingOtherSpecializations = ((model) => {
  return showSpecializationFilterMessage(model) &&
    !specializationFilterActivated(model);
}).pwPipe(memoizePerRender);

export const showSpecializationFilterMessage = ((model) => {
  return (route === "/specialties/:id" &&
    _.includes(["specialists", "clinics"], collectionShownName(model)) &&
    ((
      withAllFilters(model).length > 0 &&
      activatedFilterSubkeys.procedures(model).length > 0 &&
      withoutSpecializationFilter(model).length > withAllFilters(model).length
    ) ||
    (
      withAllFilters(model).length === 0 &&
      activatedFilterSubkeys.procedures(model).length > 0 &&
      withoutSpecializationFilter(model).length > 0
    )))
}).pwPipe(memoizePerRender);

export const withAllFilters = ((model) => {
  return unscopedCollectionShown(model).filter((record) => {
    return matchesPreliminaryFilters(record, model) &&
      matchesRoute(record, model) &&
      matchesSidebarFilters(record, model)
  })
}).pwPipe(memoizePerRender);

export const withoutSpecializationFilter = ((model) => {
  return unscopedCollectionShown(model).filter((record) => {
    return matchesPreliminaryFilters(record, model) &&
      matchesSidebarFilters(record, model)
  })
}).pwPipe(memoizePerRender);

export const withoutCityFilters = ((model) => {
  return unscopedCollectionShown(model).filter((record) => {
    return matchesPreliminaryFilters(record, model) &&
      matchesRoute(record, model) &&
      matchesSidebarFiltersExceptCities(record, model)
  })
}).pwPipe(memoizePerRender)

export const showCityFilterPills = (model) => {
  return _.includes(["specialists", "clinics"], collectionShownName(model)) &&
    withAllFilters(model).length === 0 &&
    !showSpecializationFilterMessage(model) &&
    withoutCityFilters(model).length > 0;
}


const specializationFilterActivated = (model) => {
  return _.get(
    model,
    ["ui", "tabs", selectedTabKey(model), "specializationFilterActivated"],
    false
  );
}
