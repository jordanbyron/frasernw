import { matchedRoute, matchedRouteParams } from "controller_helpers/routing";

export default function(model) {
  if (matchedRoute(model) === "/specialties/:id"){
    return model.app.specializations[matchedRouteParams(model).id];
  }
}
