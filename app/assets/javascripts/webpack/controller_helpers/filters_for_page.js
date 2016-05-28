import _ from "lodash";
import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import { collectionShownName } from "controller_helpers/collection_shown";
import { recordShownByTab } from "controller_helpers/tab_keys";

export const sidebarFilterKeys = (model) => {
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
  else {
    return [];
  }
};

export const preliminaryFilterKeys = (model) => {
  if(_.includes(["/specialties/:id", "/areas_of_practice/:id"], matchedRoute(model))&&
    _.includes(["specialists", "clinics"], collectionShownName(model))){

    return [
      "status",
      "showInTable"
    ];
  }
  else {
    return [];
  }
};
