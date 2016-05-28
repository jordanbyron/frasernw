import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import { matchesTab, matchesRoute, collectionShownName, unscopedCollectionShown }
  from "controller_helpers/collection_shown";
import { selectedTabKey, isTabbedPage } from "controller_helpers/tab_keys";
import { sidebarFilterKeys, preliminaryFilterKeys }
  from "controller_helpers/filters_for_page";
import sidebarFilters from "controller_helpers/sidebar_filters";
import * as preliminaryFilters from "controller_helpers/preliminary_filters";

const recordsToDisplay = (model) => {
  if(_.includes(["/specialties/:id", "/areas_of_practice/:id", "/content_categories/:id"],
    matchedRoute(model))) {

    if (matchedRoute(model) === "/specializations/:id" &&
      _.includes(["specialists", "clinics"], collectionShownName(model)) &&
      showingOtherSpecializations(model)){

      return unscopedCollectionShown(model).filter((record) => {
        return matchesPreliminaryFilters(record, model) &&
          matchesTab(record, model.app.contentCategories, selectedTabKey(model)) &&
          matchesSidebarFilters(record, model)
      })
    }
    else {
      return unscopedCollectionShown(model).filter((record) => {
        return matchesPreliminaryFilters(record, model) &&
          matchesRoute(matchedRoute(model), recordShownByPage(model), record) &&
          (!isTabbedPage(model) ||
            matchesTab(record, model.app.contentCategories, selectedTabKey(model))) &&
          matchesSidebarFilters(record, model)
      })
    }
  } else {
    return model.ui.recordsToDisplay;
  }
}

const matchesSidebarFilters = (record, model) => {
  return activatedSidebarFilters(model).every((filter) => {
    return filter.predicate(record, model);
  });
}

const activatedSidebarFilters = (model) => {
  return sidebarFilterKeys(model).
    map((filterKey) => sidebarFilters[filterKey]).
    filter((filter) => {
      return filter.isActivated(model);
    });
}

const boundPreliminaryFilters = (model) => {
  return preliminaryFilterKeys(model).
    map((filterKey) => preliminaryFilters[filterKey])
}

const matchesPreliminaryFilters = (record, model) => {
  return boundPreliminaryFilters(model).every((filter) => {
    return filter(record);
  })
};

export default recordsToDisplay;
