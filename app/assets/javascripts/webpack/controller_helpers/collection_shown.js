import { route, routeParams, recordShownByRoute, matchesRoute}
  from "controller_helpers/routing";
import { selectedTabKey, recordShownByTab } from "controller_helpers/nav_tab_keys";
import { memoizePerRender } from "utils";
import { isTabbedPage } from "controller_helpers/nav_tab_keys";
import * as filterValues from "controller_helpers/filter_values";
import { recordShownByBreadcrumb } from "controller_helpers/breadcrumbs";
import { matchesTabKey } from "controller_helpers/nav_tab_key";
import _ from "lodash";

export const collectionShownName = ((model) => {
  if (isTabbedPage(model)){
    if (selectedTabKey(model).includes("specialists")) {
      return "specialists";
    }
    else if (selectedTabKey(model).includes("clinics")) {
      return "clinics";
    }
    else if (selectedTabKey(model).includes("contentCategory")){
      return "contentItems";
    }
    else if (route === "/news_items"){
      return "newsItems";
    }
    else if (route === "/issues") {
      return "issues";
    }
    else if (route === "/change_requests") {
      return "changeRequests";
    }
  }
  else if (route === "/content_categories/:id"){
    return "contentItems";
  }
  else if (route === "/reports/referents_by_specialty"){
    if(filterValues.reportStyle(model) === "summary"){
      return "specializations";
    }
    else {
      return filterValues.entityType(model);
    }
  }
}).pwPipe(memoizePerRender)

export const unscopedCollectionShown = ((model) => {
  if (route === "/latest_updates") {
    return model.ui.latestUpdates;
  }
  else {
    return model.app[collectionShownName(model)].pwPipe(_.values);
  }
}).pwPipe(memoizePerRender)

export const scopedByRouteAndTab = ((model) => {
  return unscopedCollectionShown(model).filter((record) => {
    return matchesRoute(record, model) &&
      (!isTabbedPage(model) || matchesTabKey(record, model, selectedTabKey(model)));
  });
}).pwPipe(memoizePerRender)

export const collectionShownPluralLabel = ((model) => {
  switch(collectionShownName(model)){
  case "specialists":
    if (route === "/specialties/:id"){
      return recordShownByRoute(model).membersName;
    } else {
      return "Specialists"
    }
  case "clinics":
    if (route === "/specialties/:id"){
      return `${recordShownByRoute(model).name} Clinics`;
    } else {
      return "Clinics"
    }
  case "contentItems":
    if (route === "/content_categories/:id") {
      return recordShownByRoute(model).name;
    }
    else {
      return recordShownByTab(model).name;
    }
  default:
    return _.capitalize(collectionShownName(model));
  }
}).pwPipe(memoizePerRender);
