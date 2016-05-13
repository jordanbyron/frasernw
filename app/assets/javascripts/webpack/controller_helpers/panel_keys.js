import { matchedRoute, matchedRouteParams } from "controller_helpers/routing";

export function defaultPanel(model) {
  return {
    ["/specialties/:id"]: function() {
      return model.
        app.
        divisions[model.app.currentUser.divisionIds[0]].
        openToSpecializationPanel[matchedRouteParams(model).id];
    },
    ["/areas_of_practice/:id"]: function() {
      return { type: "specialists" }
    }
  }[matchedRoute(model)]();
};



export function selectedPanelKey(model){
  return (model.ui.location.query.tabKey ||
    panelKey(defaultPanel(model).type, defaultPanel(model).id));
};

export function panelKey(collection, id) {
  if (id) {
    return (collection + id);
  } else {
    return collection;
  }
};
