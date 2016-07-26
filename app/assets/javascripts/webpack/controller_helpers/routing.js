import UrlPattern from 'url-pattern';
import { memoizePerRender } from "utils";

export const Routes = [
  "/specialties/:id",
  "/areas_of_practice/:id",
  "/content_categories/:id",
  "/reports/entity_page_views",
  "/reports/referents_by_specialty",
  "/latest_updates",
  "/reports/page_views_by_user",
  "/hospitals/:id",
  "/languages/:id",
  "/news_items",
  "/issues",
  "/change_requests",
  "/clinics/:id",
  "/specialists/:id",
  "/faq_categories/:id",
  "/referral_forms",
  "/content_items/:id",
  "/terms_and_conditions",
  "/",
];

export const matchedRoute = ((model) => {
  return _.find(Routes, (route) => {
    return !(routeParams(model.ui.pathname, route) === null);
  });
}).pwPipe(memoizePerRender);

export const matchedRouteParams = ((model) => {
  return routeParams(model.ui.pathname, matchedRoute(model));
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
  case "/news_items":
    return model.app.divisions[model.ui.persistentConfig.divisionId];
  }
}).pwPipe(memoizePerRender)

const routeParams = (pathname, route) => {
  const pattern = new UrlPattern(route);

  return pattern.match(pathname);
};
