import {
  matchedRoute,
  matchedRouteParams,
  recordShownByRoute
} from "controller_helpers/routing";
import { memoizePerRender } from "utils";
import recordShownByBreadcrumb from "controller_helpers/record_shown_by_breadcrumb";

export const defaultTab = ((model) => {
  switch(matchedRoute(model)){
  case "/specialties/:id":
    return model.app.divisions[model.app.currentUser.divisionIds[0]].
      openToSpecializationPanel[matchedRouteParams(model).id];
  case "/areas_of_practice/:id":
    return { type: "specialists" };
  case "/hospitals/:id":
    return { type: "specialistsWithPrivileges" };
  case "/languages/:id":
    return { type: "specialists" };
  case "/news_items":
    return { type: "ownedNewsItems" };
  case "/issues":
    return { type: "pendingIssues" };
  case "/change_requests":
    return { type: "pendingIssues" };
  default:
    return { type: "only" };
  }
}).pwPipe(memoizePerRender)

const ALWAYS_IN_ROUTES = [
  "/specialties/:id",
  "/areas_of_practice/:id",
  "/hospitals/:id",
  "/languages/:id",
  "/news_items",
  "/issues",
  "/change_requests"
];

export const isTabbedPage = ((model) => {
  return _.includes(ALWAYS_IN_ROUTES, matchedRoute(model)) ||
    (_.includes(
      ["/specialists/:id", "/clinics/:id", "/content_items/:id"],
      matchedRoute(model)
    ) && recordShownByBreadcrumb(model));
}).pwPipe(memoizePerRender);

export const selectedTabKey = ((model) => {
  if (matchedRoute(model) === "/specialists/:id"){
    return "specialists";
  }
  else if (matchedRoute(model) === "/clinics/:id"){
    return "clinics";
  }
  else if (matchedRoute(model) === "/content_items/:id"){
    return tabKey("contentCategory", recordShownByRoute(model).rootCategoryId);
  }
  else {
    return (model.ui.selectedTabKey ||
      tabKey(defaultTab(model).type, defaultTab(model).id));
  }
}).pwPipe(memoizePerRender);

const extractId = (tabKey) => {
  return parseInt(tabKey.match(/\d+/));
}

export const recordShownByTab = ((model) => {
  if(selectedTabKey(model).includes("contentCategory")){
    return model.app.contentCategories[extractId(selectedTabKey(model))];
  }
  else {
    return {};
  }
}).pwPipe(memoizePerRender)

export function tabKey(type, id) {
  if (id) {
    return (type + id);
  } else {
    return type;
  }
};
