import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import { matchesTab, matchesRoute, collectionShownName, unscopedCollectionShown }
  from "controller_helpers/collection_shown";
import { showingOtherSpecializations } from "controller_helpers/filter_messages";
import { selectedTabKey, isTabbedPage } from "controller_helpers/tab_keys";
import matchesPreliminaryFilters from "controller_helpers/matches_preliminary_filters";
import matchesSidebarFilters from "controller_helpers/matches_sidebar_filters";
import { memoizePerRender } from "utils";

const recordsToDisplay = ((model) => {
  if(_.includes([
      "/specialties/:id",
      "/areas_of_practice/:id",
      "/content_categories/:id",
      "/reports/referents_by_specialty",
      "/latest_updates",
      "/hospitals/:id"
    ], matchedRoute(model))) {

    if (matchedRoute(model) === "/specialties/:id" &&
      showingOtherSpecializations(model)){

      return unscopedCollectionShown(model).filter((record) => {
        return matchesPreliminaryFilters(record, model) &&
          matchesSidebarFilters(record, model)
      })
    }
    else {
      return unscopedCollectionShown(model).filter((record) => {
        return matchesPreliminaryFilters(record, model) &&
          matchesRoute(matchedRoute(model), recordShownByPage(model), record) &&
          (!isTabbedPage(model) ||
          matchesTab(
            record,
            model.app.contentCategories,
            selectedTabKey(model),
            recordShownByPage(model)
          )) && matchesSidebarFilters(record, model)
      })
    }
  } else {
    return model.ui.recordsToDisplay;
  }
}).pwPipe(memoizePerRender)

export default recordsToDisplay;
