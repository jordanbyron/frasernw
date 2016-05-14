import UrlPattern from 'url-pattern';
import { memoize } from "utils";

export const Routes = [
  "/specialties/:id",
  "/areas_of_practice/:id",
  "/content_categories/:id",
  "/reports/usage",
  "/reports/referents_by_specialty",
  "/latest_updates",
  "/reports/pageviews_by_user"
]

const pathname = (model) => model.ui.location.pathname;

export const matchedRoute = memoize(
  pathname,
  (pathname) => {
    return _.find(Routes, (route) => {
      return !(routeParams(pathname, route) === null);
    });
  }
);

export const matchedRouteParams = memoize(
  pathname,
  matchedRoute,
  (pathname, matchedRoute) => {
    return routeParams(pathname, matchedRoute);
  }
);

export function recordShownByPage(model) {
  if (matchedRoute(model) === "/specialties/:id"){
    return model.app.specializations[matchedRouteParams(model).id];
  }
  else if (matchedRoute(model) === "/areas_of_practice/:id"){
    return model.app.procedures[matchedRouteParams(model).id];
  }
  else if (matchedRoute(model) === "/content_categories/:id"){
    return model.app.contentCategories[matchedRouteParams(model).id];
  }
  else {
    return null;
  }
};

const routeParams = (pathname, route) => {
  const pattern = new UrlPattern(route);

  return pattern.match(pathname);
};
