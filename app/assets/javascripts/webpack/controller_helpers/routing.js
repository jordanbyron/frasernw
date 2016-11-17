import UrlPattern from 'url-pattern';
import { memoizePerRender } from "utils";

export const Routes = [
  "/specialties/:id",
  "/areas_of_practice/:id",
  "/content_categories/:id",
  "/reports/entity_page_views",
  "/reports/profiles_by_specialty",
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

const pathnameRouteParams = (pathname, _route) => {
  if(_route) {
    return (new UrlPattern(_route)).match(pathname)
  }
  else {
    return undefined;
  }
}

export const route = _.find(Routes, (_route) => {
  return pathnameRouteParams(window.location.pathname, _route) !== null;
});
export const routeParams = pathnameRouteParams(window.location.pathname, route)

export const recordShownByRoute = ((model) => {
  switch(route){
  case "/specialties/:id":
    return model.app.specializations[routeParams.id];
  case "/areas_of_practice/:id":
    return model.app.procedures[routeParams.id];
  case "/content_categories/:id":
    return model.app.contentCategories[routeParams.id];
  case "/hospitals/:id":
    return model.app.hospitals[routeParams.id];
  case "/languages/:id":
    return model.app.languages[routeParams.id];
  case "/specialists/:id":
    return model.app.specialists[routeParams.id];
  case "/clinics/:id":
    return model.app.clinics[routeParams.id];
  case "/content_items/:id":
    return model.app.contentItems[routeParams.id];
  case "/news_items":
    return model.app.divisions[model.ui.persistentConfig.divisionId];
  }
}).pwPipe(memoizePerRender)

export const matchesRoute = (record, model) => {
  switch(route){
  case "/specialties/:id":
    return _.includes(
      record.specializationIds,
      recordShownByRoute(model).id
    );
  case "/areas_of_practice/:id":
    return _.includes(
      record.procedureIds,
      recordShownByRoute(model).id
    ) || _.intersection(
      record.specializationIds,
      recordShownByRoute(model).assumedSpecializationIds[record.collectionName]
    ).pwPipe(_.any);
  case "/content_categories/:id":
    return _.includes(
      recordShownByRoute(model).subtreeIds,
      record.categoryId
    )
  case "/languages/:id":
    return _.includes(
      record.languageIds,
      recordShownByRoute(model).id
    );
  default:
    return true;
  }
};
