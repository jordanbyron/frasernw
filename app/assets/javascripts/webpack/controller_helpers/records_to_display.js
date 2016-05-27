import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import { matchesTab, matchesRoute, collectionShownName, unscopedCollectionShown }
  from "controller_helpers/collection_shown";
import { selectedTabKey, isTabbedPage } from "controller_helpers/tab_keys";
import { sidebarFiltersForPage, preliminaryFiltersForPage }
  from "controller_helpers/filters_for_page";

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
  return sidebarFiltersForPage(model).filter((filter) => {
    return filter.isActivated(model)
  });
}

const matchesPreliminaryFilters = (record, model) => {
  return preliminaryFiltersForPage(model).every((filter) => {
    return filter(record);
  })
}

export default recordsToDisplay;
