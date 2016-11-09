import {
  route,
  routeParams,
  recordShownByRoute
} from "controller_helpers/routing";
import { memoizePerRender } from "utils";
import recordShownByBreadcrumb from "controller_helpers/record_shown_by_breadcrumb";
import contentCategoryItems from "controller_helpers/content_category_items";
import { navTabKey } from "controller_helpers/nav_tab_key";
import { matchesPage } from "controller_helpers/collection_shown";

const navTabKeys = ((model) => {
  switch(route){
  case "/hospitals/:id":
    return [ "specialistsWithPrivileges", "clinicsIn", "specialistsWithOffices" ];
  case "/news_items":
    return [ "ownedNewsItems", "showingNewsItems", "availableNewsItems" ];
  case "/change_requests":
  case "/issues":
    return [ "pendingIssues", "closedIssues" ];
  case "/languages/:id":
    return [ "specialists", "clinics" ];
  default:
    return [ "specialists", "clinics" ].concat(contentCategoryTabKeys(model))
  }
}).pwPipe(memoizePerRender)

export const selectedTabKey = ((model) => {
  if (isTabbedPage(model)){
    return (model.ui.selectedTabKey || defaultTabKey(model) || navTabKeys(model).first)
  }
  else {
    return navTabKey("only");
  }
}).pwPipe(memoizePerRender);

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

const profileKeys = (model) => {
  return [
    "specialists",
    "clinics"
  ].filter((key) => {
    return model.app[key].filter((profile) => {
      return matchesPage(record, model)
    }).length > 0
  })
}

const contentCategoryTabKeys = (model) => {
  return contentCategoriesShowingTabs(model).
    sort((category) => category.name === "Virtual Consult" ? 0 : 1).
    map((category) => navTabKey("contentCategory", category.id) );
}

const contentCategoriesShowingTabs = (model) => {
  return _.filter(
    model.app.contentCategories,
    (category) => {
      return (
        category.ancestry == null &&
        contentCategoryItems(
          category.id,
          model
        ).pwPipe(_.keys).pwPipe(_.some)
      );
    }
  ).pwPipe(_.values);
};
