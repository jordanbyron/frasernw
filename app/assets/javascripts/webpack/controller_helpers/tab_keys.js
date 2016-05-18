import { matchedRoute, matchedRouteParams } from "controller_helpers/routing";

export function defaultTab(model) {
  switch(matchedRoute(model)){
  case "/specialties/:id":
    return model.
      app.
      divisions[model.app.currentUser.divisionIds[0]].
      openToSpecializationPanel[matchedRouteParams(model).id];
  case "/areas_of_practice/:id":
    return { type: "specialists" };
  default:
    return { type: "only" };
  }
};

export function selectedTabKey(model){
  return (model.ui.location.query.tabKey ||
    tabKey(defaultTab(model).type, defaultTab(model).id));
};

const extractId = (tabKey) => {
  return parseInt(tabKey.match(/\d+/));
}

export function recordShownByTab(model){
  if(selectedTabKey(model).includes("contentCategory")){
    return model.app.contentCategories[extractId(selectedTabKey(model))];
  }
}

export function tabKey(type, id) {
  if (id) {
    return (type + id);
  } else {
    return type;
  }
};
