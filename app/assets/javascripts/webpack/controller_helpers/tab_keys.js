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

export function recordShownByTab(model){
  if(selectedTabKey(model).includes("contentCategories")){
    const id = _.replace(selectedTabKey(model), "contentCategories", "")

    return model.app.contentCategories[id];
  }
}

export function tabKey(collection, id) {
  if (id) {
    return (collection + id);
  } else {
    return collection;
  }
};
