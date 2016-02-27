import UrlPattern from 'url-pattern';

export const Routes = [
  "/specialties/:id",
  "/areas_of_practice/:id",
  "/content_categories/:id",
  "/reports/usage",
  "/reports/referents_by_specialty",
  "/latest_updates"
]

export function matchedRoute(location) {
  return _.find(Routes, (route) => {
    return !(routeParams(location.pathname, route) === null);
  });
};

export function routeParams(pathname, route) {
  const pattern = new UrlPattern(route);

  return pattern.match(pathname);
};

export default Routes;
