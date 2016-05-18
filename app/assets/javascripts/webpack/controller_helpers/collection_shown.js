import { matchedRoute, matchedRouteParams, recordShownByPage }
  from "controller_helpers/routing";
import { selectedTabKey, recordShownByTab } from "controller_helpers/tab_keys";
import { memoize } from "utils";

export function unscopedCollectionShown(model){
  return model.app[collectionShownName(model)].pwPipe(_.values);
};

export const scopedByRouteAndTab = memoize(
  selectedTabKey,
  model => model,
  (selectedTabKey, model) => {
    return unscopedCollectionShown(model).filter((record) => {
      return matchesRoute(matchedRoute(model), recordShownByPage(model), record) &&
        matchesTab(record, model, selectedTabKey);
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
  if (_.includes(["specialists", "clinics"], selectedTabKey(model))){
    return selectedTabKey(model);
  }
  else if (selectedTabKey(model).includes("contentCategory")){
    return "contentItems";
  }
};
