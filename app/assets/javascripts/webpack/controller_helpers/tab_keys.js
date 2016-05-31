import { matchedRoute, matchedRouteParams } from "controller_helpers/routing";
import { memoizePerRender } from "utils";

export const defaultTab = ((model) => {
  switch(matchedRoute(model)){
  case "/specialties/:id":
    return model.app.divisions[model.app.currentUser.divisionIds[0]].
      openToSpecializationPanel[matchedRouteParams(model).id];
  case "/areas_of_practice/:id":
    return { type: "specialists" };
  case "/hospitals/:id":
    return { type: "specialistsWithPrivileges" };
  default:
    return { type: "only" };
  }
}).pwPipe(memoizePerRender)

const SHOWING_IN_ROUTES = [
  "/specialties/:id",
  "/areas_of_practice/:id",
  "/hospitals/:id"
];

export const isTabbedPage = ((model) => {
  return _.includes(SHOWING_IN_ROUTES, matchedRoute(model));
}).pwPipe(memoizePerRender);

export const selectedTabKey = ((model) => {
  return (model.ui.location.hash.replace("#", "") ||
    tabKey(defaultTab(model).type, defaultTab(model).id));
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
