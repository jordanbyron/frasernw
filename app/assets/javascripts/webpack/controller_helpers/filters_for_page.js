import _ from "lodash";
import { matchedRoute } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";
import sidebarFilters from "controller_helpers/sidebar_filters";
import * as preliminaryFilters from "controller_helpers/preliminary_filters";
import { recordShownByTab } from "controller_helpers/tab_keys";


export const sidebarFiltersForPage = (model) => {
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
      ].pwPipe(matchSidebarFilters);
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
      ].pwPipe(matchSidebarFilters);
    }
    else if (collectionShownName(model) === "contentItems" &&
      recordShownByTab(model).componentType === "FilterTable"){

      return [
        "subcategories"
      ].pwPipe(matchSidebarFilters);
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
    ].pwPipe(matchSidebarFilters);
  }
  else {
    return [];
  }
}

export const preliminaryFiltersForPage = (model) => {
  if(_.includes(["/specialties/:id", "/areas_of_practice/:id"], matchedRoute(model))&&
    _.includes(["specialists", "clinics"], collectionShownName(model))){

    return [
      "status",
      "showInTable"
    ].pwPipe(matchPreliminaryFilters);
  }
  else {
    return [];
  }
}

const matchSidebarFilters = (filterKeys) => {
  return filterKeys.map((key) => sidebarFilters[key])
};

const matchPreliminaryFilters = (filterKeys) => {
  return filterKeys.map((key) => preliminaryFilters[key])
};
