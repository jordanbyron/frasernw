import { route, recordShownByRoute } from "controller_helpers/routing";
import {
  matchesTab,
  matchesPage,
  collectionShownName,
  unscopedCollectionShown,
  scopedByRouteAndTab
} from "controller_helpers/collection_shown";
import recordShownByBreadcrumb from "controller_helpers/record_shown_by_breadcrumb";
import { showingOtherSpecializations } from "controller_helpers/filter_messages";
import { selectedTabKey, isTabbedPage } from "controller_helpers/nav_tab_keys";
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
      "/hospitals/:id",
      "/languages/:id",
      "/news_items",
      "/issues",
      "/change_requests"
    ], route)) {

    if (route === "/specialties/:id" &&
      showingOtherSpecializations(model)){

      return unscopedCollectionShown(model).filter((record) => {
        return matchesPreliminaryFilters(record, model) &&
          matchesSidebarFilters(record, model)
      })
    }
    else {
      return unscopedCollectionShown(model).filter((record) => {
        return matchesPreliminaryFilters(record, model) &&
          matchesPage(record, model) &&
          (!isTabbedPage(model) ||
            matchesTab(record, model, selectedTabKey(model))) &&
          matchesSidebarFilters(record, model)
      })
    }
  }
  else {
    return model.ui.recordsToDisplay;
  }
}).pwPipe(memoizePerRender)

export default recordsToDisplay;
