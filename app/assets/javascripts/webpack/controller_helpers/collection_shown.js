import { matchedRoute, matchedRouteParams, recordShownByPage }
  from "controller_helpers/routing";
import { selectedTabKey, recordShownByTab } from "controller_helpers/tab_keys";
import { memoizePerRender } from "utils";
import { isTabbedPage } from "controller_helpers/tab_keys";

export const collectionShownName = ((model) => {
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
}).pwPipe(memoizePerRender)

export const unscopedCollectionShown = ((model) => {
  return model.app[collectionShownName(model)].pwPipe(_.values);
}).pwPipe(memoizePerRender)

export const scopedByRouteAndTab = ((model) => {
  return unscopedCollectionShown(model).filter((record) => {
    return matchesRoute(matchedRoute(model), recordShownByPage(model), record) &&
      (!isTabbedPage(model) ||
        matchesTab(record, model.app.contentCategories, selectedTabKey(model)));
  });
}).pwPipe(memoizePerRender)

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

export const collectionShownPluralLabel = ((model) => {
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
}).pwPipe(memoizePerRender);
