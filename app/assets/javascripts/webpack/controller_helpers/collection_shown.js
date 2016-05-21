import { matchedRoute, matchedRouteParams, recordShownByPage }
  from "controller_helpers/routing";
import { selectedTabKey, recordShownByTab } from "controller_helpers/tab_keys";
import { memoize } from "utils";
import { SHOWING_IN_ROUTES as tabsShownInRoutes } from "controllers/nav_tabs";

export function unscopedCollectionShown(model){
  return model.app[collectionShownName(model)].pwPipe(_.values);
};

export const isTabbedPage = (model) => {
  return _.includes(tabsShownInRoutes, matchedRoute(model));
};

export const scopedByRouteAndTab = memoize(
  selectedTabKey,
  isTabbedPage,
  model => model,
  (selectedTabKey, isTabbedPage, model) => {
    return unscopedCollectionShown(model).filter((record) => {
      return matchesRoute(matchedRoute(model), recordShownByPage(model), record) &&
        (!isTabbedPage || matchesTab(record, model, selectedTabKey));
    });
  }
);

export const matchesRoute = (matchedRoute, recordShownByPage, record) => {
  switch(matchedRoute){
  case "/specialties/:id":
    return _.includes(
      record.specializationIds,
      recordShownByPage.id
    );
  case "/procedures/:id":
    return _.includes(
      record.procedureIds,
      recordShownByPage.id
    )
  case "/content_categories/:id":
    return _.includes(
      recordShownByPage.subtreeIds,
      record.categoryId
    )
  }
};

export const matchesTab = (record, model, tabKey) => {
  let _tabKey = tabKey || selectedTabKey(model);

  if (_.includes(["specialists", "clinics"], _tabKey)){
    return true;
  }
  else if (_tabKey.includes("contentCategory")){
    let contentCategory =
      model.app.contentCategories[_tabKey.replace("contentCategory", "")]

    return _.includes(
      contentCategory.subtreeIds,
      record.categoryId
    );
  }
}

export function collectionShownName(model){
  if (isTabbedPage(model)){
    if (_.includes(["specialists", "clinics"], selectedTabKey(model))){
      return selectedTabKey(model);
    }
    else if (selectedTabKey(model).includes("contentCategory")){
      return "contentItems";
    }
  }
  else if (matchedRoute(model) === "/content_categories/:id"){
    return "contentItems";
  }
};