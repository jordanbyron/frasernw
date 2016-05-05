import UrlPattern from 'url-pattern';

export const Routes = [
  "/specialties/:id",
  "/areas_of_practice/:id",
  "/content_categories/:id",
  "/reports/usage",
  "/reports/referents_by_specialty",
  "/latest_updates",
  "/reports/pageviews_by_user"
]

export function matchedRoute(model) {
  return _.find(Routes, (route) => {
    return !(routeParams(model.ui.location.pathname, route) === null);
  });
};

export function matchedRouteParams(model) {
  return routeParams(model.ui.location.pathname, matchedRoute(model));
};

const routeParams = (pathname, route) => {
  const pattern = new UrlPattern(route);

  return pattern.match(pathname);
};
