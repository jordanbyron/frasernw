import { matchedRoute, matchedRouteParams } from "controller_helpers/routing";

export default function(model) {
  if (matchedRoute(model) === "/specialties/:id"){
    return model.app.specializations[matchedRouteParams(model).id];
  }
  else if (matchedRoute(model) === "/areas_of_practice/:id"){
    return model.app.procedures[matchedRouteParams(model).id];
  }
  else {
    return null;
  }
};
