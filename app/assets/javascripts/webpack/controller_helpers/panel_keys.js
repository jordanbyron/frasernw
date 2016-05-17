import { matchedRoute, matchedRouteParams } from "controller_helpers/routing";

export function defaultPanel(model) {
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

export function selectedPanelKey(model){
  return (model.ui.location.query.tabKey ||
    panelKey(defaultPanel(model).type, defaultPanel(model).id));
};

export function recordShownByPanel(model){
  if(selectedPanelKey(model).includes("contentCategories")){
    const id = _.replace(selectedPanelKey(model), "contentCategories", "")

    return model.app.contentCategories[id];
  }
}

export function panelKey(collection, id) {
  if (id) {
    return (collection + id);
  } else {
    return collection;
  }
};
