import { matchedRoute, matchedRouteParams, recordShownByPage }
  from "controller_helpers/routing";
import { selectedTabKey, recordShownByTab } from "controller_helpers/tab_keys";
import { memoize } from "utils";
import { isTabbedPage } from "controller_helpers/tab_keys";

export const collectionShownName = memoize(
  isTabbedPage,
  selectedTabKey,
  matchedRoute,
  (isTabbedPage, selectedTabKey, matchedRoute) => {
    if (isTabbedPage){
      if (_.includes(["specialists", "clinics"], selectedTabKey)){
        return selectedTabKey;
      }
      else if (selectedTabKey.includes("contentCategory")){
        return "contentItems";
      }
    }
    else if (matchedRoute === "/content_categories/:id"){
      return "contentItems";
    }
  }
);

export const unscopedCollectionShown = memoize(
  (model) => model.app,
  collectionShownName,
  (app, collectionShownName) => {
    return app[collectionShownName].pwPipe(_.values);
  }
);

export const scopedByRouteAndTab = memoize(
  selectedTabKey,
  isTabbedPage,
  matchedRoute,
  recordShownByPage,
  unscopedCollectionShown,
  (model) => (model.app.contentCategories),
  (
    selectedTabKey,
    isTabbedPage,
    matchedRoute,
    recordShownByPage,
    unscopedCollectionShown,
    contentCategories
  ) => {
    return unscopedCollectionShown.filter((record) => {
      return matchesRoute(matchedRoute, recordShownByPage, record) &&
        (!isTabbedPage || matchesTab(record, contentCategories, selectedTabKey));
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
    // TODO: assumed

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

export const matchesTab = (record, contentCategories, tabKey) => {
  if (_.includes(["specialists", "clinics"], tabKey)){
    return true;
  }
  else if (tabKey.includes("contentCategory")){
    let contentCategory =
      contentCategories[tabKey.replace("contentCategory", "")]

    return _.includes(
      contentCategory.subtreeIds,
      record.categoryId
    );
  }
};

export const collectionShownPluralLabel = (model) => {
  switch(collectionShownName(model)){
  case "specialists":
    if (matchedRoute(model) === "/specialties/:id"){
      return recordShownByPage(model).membersName;
    } else {
      return "Specialists"
    }
  case "clinics":
    if (matchedRoute(model) === "/specialties/:id"){
      return `${recordShownByPage(model).name} Clinics`;
    } else {
      return "Clinics"
    }
  case "contentItems":
    if (matchedRoute(model) === "/content_categories/:id") {
      return recordShownByPage(model).name;
    }
    else {
      return recordShownByTab(model).name;
    }
  }
};
