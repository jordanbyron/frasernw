import UrlPattern from 'url-pattern';
import { memoizePerRender } from "utils";

export const Routes = [
  "/specialties/:id",
  "/areas_of_practice/:id",
  "/content_categories/:id",
  "/reports/entity_page_views",
  "/reports/referents_by_specialty",
  "/latest_updates",
  "/reports/pageviews_by_user",
  "/hospitals/:id",
  "/languages/:id"
];

export const matchedRoute = ((model) => {
  return _.find(Routes, (route) => {
    return !(routeParams(model.ui.location.pathname, route) === null);
  });
}).pwPipe(memoizePerRender);

export const matchedRouteParams = ((model) => {
  return routeParams(model.ui.location.pathname, matchedRoute(model));
}).pwPipe(memoizePerRender);

export const recordShownByPage = ((model) => {
  switch(matchedRoute(model)){
  case "/specialties/:id":
    return model.app.specializations[matchedRouteParams(model).id];
  case "/areas_of_practice/:id":
    return model.app.procedures[matchedRouteParams(model).id];
  case "/content_categories/:id":
    return model.app.contentCategories[matchedRouteParams(model).id];
  case "/hospitals/:id":
    return model.app.hospitals[matchedRouteParams(model).id];
  case "/languages/:id":
    return model.app.languages[matchedRouteParams(model).id];
  }
}).pwPipe(memoizePerRender)

const routeParams = (pathname, route) => {
  const pattern = new UrlPattern(route);

  return pattern.match(pathname);
};
