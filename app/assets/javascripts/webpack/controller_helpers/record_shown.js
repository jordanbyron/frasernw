export default function(model) {
  if (matchedRoute(model) === "/specializations/:id"){
    return model.app.specializations[matchedRouteParams(model).id];
  }
}
