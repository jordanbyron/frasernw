import {
  route,
  routeParams,
  recordShownByRoute,
  matchesRoute
} from "controller_helpers/routing";
import { memoizePerRender } from "utils";
import { recordShownByBreadcrumb, matchesBreadcrumb } from "controller_helpers/breadcrumbs";
import { navTabKey, recordShownByTabKey, matchesTabKey } from "controller_helpers/nav_tab_key";
import * as preliminaryFilters from "controller_helpers/preliminary_filters";
import { preliminaryFilterKeys } from "controller_helpers/matches_preliminary_filters";

export const navTabKeys = ((model) => {
  switch(route){
  case "/hospitals/:id":
    return [ "specialistsWithPrivileges", "clinicsIn", "specialistsWithOffices" ];
  case "/news_items":
    return [ "ownedNewsItems", "showingNewsItems", "availableNewsItems" ];
  case "/change_requests":
  case "/issues":
    return [ "pendingIssues", "closedIssues" ];
  case "/languages/:id":
    return profileTabKeys(model);
  default:
    return profileTabKeys(model).concat(contentCategoryTabKeys(model));
  }
}).pwPipe(memoizePerRender)

export const selectedTabKey = ((model) => {
  if (isTabbedPage(model)){
    return (model.ui.selectedTabKey || defaultTabKey(model) || navTabKeys(model)[0])
  }
  else {
    return navTabKey("only");
  }
}).pwPipe(memoizePerRender);

export const recordShownByTab = ((model) => {
  return recordShownByTabKey(model, selectedTabKey(model));
}).pwPipe(memoizePerRender)

export const defaultTabKey = ((model) => {
  switch(route){
  case "/specialties/:id":
    let config = model.app.divisions[model.app.currentUser.divisionIds[0]].
      openToSpecializationPanel[routeParams.id];

    return navTabKey(config.type, config.id);
  case "/specialists/:id":
    return navTabKey("specialists");
  case "/clinics/:id":
    return navTabKey("clinics");
  case "/content_items/:id":
    return navTabKey("contentCategory", recordShownByRoute(model).rootCategoryId);
  default:
    return null;
  }
}).pwPipe(memoizePerRender)

export const isTabbedPage = ((model) => {
  return _.includes(ALWAYS_IN_ROUTES, route) ||
    (_.includes(
      ["/specialists/:id", "/clinics/:id", "/content_items/:id"],
      route
    ) && recordShownByBreadcrumb(model));
}).pwPipe(memoizePerRender);

const ALWAYS_IN_ROUTES = [
  "/specialties/:id",
  "/areas_of_practice/:id",
  "/hospitals/:id",
  "/languages/:id",
  "/news_items",
  "/issues",
  "/change_requests"
];

const profileTabKeys = (model) => {
  return [
    "specialists",
    "clinics"
  ].filter((key) => {
    return scopedByPageAndPreliminaryFilters(key, model).length > 1
  });
}

const contentCategoryTabKeys = (model) => {
  return _.values(model.app.contentCategories).
    filter((category) => {
      return (
        category.ancestry == null &&
          pageContentItems(model).filter((item) => {
            return matchesTabKey(item, model, navTabKey("contentCategory", category.id));
          }).pwPipe(_.some)
      );
    }).sort((category) => category.name === "Virtual Consult" ? 0 : 1).
    map((category) => navTabKey("contentCategory", category.id) );
}

const scopedByPageAndPreliminaryFilters = (collectionName, model) => {
  const _preliminaryFilters = preliminaryFilterKeys(collectionName).
    map((filterKey) => preliminaryFilters[filterKey])

  return _.values(model.app[collectionName]).filter((item) => {
    return matchesPage(item, model) &&
      _preliminaryFilters.every((filter) => filter(item, model))
  });
};

const pageContentItems = _.partial(
  scopedByPageAndPreliminaryFilters,
  "contentItems"
).pwPipe(memoizePerRender)

const matchesPage = (record, model) => {
  switch(route){
  case "/specialties/:id":
  case "/areas_of_practice/:id":
  case "/content_categories/:id":
  case "/languages/:id":
    return matchesRoute(record, model);
  case "/specialists/:id":
  case "/clinics/:id":
  case "/content_items/:id":
    return matchesBreadcrumb(record, model);
  default:
    return true;
  }
};
