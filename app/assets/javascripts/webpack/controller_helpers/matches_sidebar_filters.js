import _ from "lodash";
import sidebarFilters from "controller_helpers/sidebar_filters";
import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";
import { recordShownByTab } from "controller_helpers/tab_keys";
import * as filterValues from "controller_helpers/filter_values";
import { memoizePerRender } from "utils";

export const sidebarFilterKeys = ((model) => {
  if(_.includes(["/specialties/:id", "/areas_of_practice/:id"], matchedRoute(model))) {
    if(collectionShownName(model) === "specialists") {
      return [
        "procedures",
        "acceptsReferralsViaPhone",
        "patientsCanCall",
        "respondsWithin",
        "sex",
        "scheduleDays",
        "interpreterAvailable",
        "languages",
        "clinicAssociations",
        "hospitalAssociations",
        "teleserviceRecipients",
        "teleserviceFeeTypes",
        "cities"
      ];
    }
    else if (collectionShownName(model) === "clinics"){
      return [
        "procedures",
        "scheduleDays",
        "languages",
        "isPublic",
        "isPrivate",
        "isWheelchairAccessible",
        "careProviders",
        "teleserviceRecipients",
        "teleserviceFeeTypes",
        "cities"
      ];
    }
    else if (collectionShownName(model) === "contentItems" &&
      recordShownByTab(model).componentType === "FilterTable"){

      return [
        "subcategories"
      ];
    }
    else {
      return [];
    }
  }
  else if (matchedRoute(model) === "/content_categories/:id" &&
    recordShownByPage(model).componentType === "FilterTable"){

    return [
      "subcategories",
      "specializations"
    ];
  }
  else if (matchedRoute(model) === "/reports/referents_by_specialty" &&
    filterValues.reportStyle(model) === "expanded"){

    return [
      "divisionScope"
    ];
  }
  else if (matchedRoute(model) === "/latest_updates"){
    return [
      "showHiddenUpdates"
    ];
  }
  else {
    return [];
  }
}).pwPipe(memoizePerRender);


const activatedSidebarFilters = ((model) => {
  return sidebarFilterKeys(model).
    map((filterKey) => sidebarFilters[filterKey]).
    filter((filter) => {
      return filter.isActivated(model);
    });
}).pwPipe(memoizePerRender);


const matchesSidebarFilters = (record, model) => {
  return activatedSidebarFilters(model).every((filter) => {
    return filter.predicate(record, model);
  });
}

const activatedSidebarFiltersExceptCities = ((model) => {
  return sidebarFilterKeys(model).
    pwPipe((keys) => _.without(keys, "cities")).
    map((filterKey) => sidebarFilters[filterKey]).
    filter((filter) => {
      return filter.isActivated(model);
    });
}).pwPipe(memoizePerRender);

export const matchesSidebarFiltersExceptCities = (record, model) => {
  return activatedSidebarFiltersExceptCities(model).every((filter) => {
    return filter.predicate(record, model);
  });
}

export default matchesSidebarFilters;
