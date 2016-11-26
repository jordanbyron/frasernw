import { route, recordShownByRoute, matchesRoute } from "controller_helpers/routing";
import {
  collectionShownName,
  unscopedCollectionShown
} from "controller_helpers/collection_shown";
import { matchesTabKey } from "controller_helpers/nav_tab_key";
import { recordShownByBreadcrumb } from "controller_helpers/breadcrumbs";
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
      "/news_items/archive",
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
          matchesRoute(record, model) &&
          (!isTabbedPage(model) ||
            matchesTabKey(record, model, selectedTabKey(model))) &&
          matchesSidebarFilters(record, model)
      })
    }
  }
  else {
    return model.ui.recordsToDisplay;
  }
}).pwPipe(memoizePerRender)

export default recordsToDisplay;
