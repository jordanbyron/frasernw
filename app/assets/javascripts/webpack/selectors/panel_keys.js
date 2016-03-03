import { route } from "selectors/routing";
import { routeParams } from "selectors/routing";

export function defaultPanel(model) {
  return {
    ["/specialties/:id"]: function() {
      return model.
        app.
        divisions[model.app.currentUser.divisionIds[0]].
        openToSpecializationPanel[routeParams(model).id];
    },
    ["/areas_of_practice/:id"]: function() {
      return { type: "specialists" }
    }
  }[route(model)]();
};

export function selectedPanelKey(model){
  return (model.ui.selectedPanel ||
    panelKey(defaultPanel(model).type, defaultPanel(model).id));
};

export function panelKey(collection, id) {
  if (id) {
    return (collection + id);
  } else {
    return collection;
  }
};
