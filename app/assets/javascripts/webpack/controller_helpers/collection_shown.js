import { matchedRoute, matchedRouteParams } from "controller_helpers/routing";
import { selectedTabKey, recordShownByTab } from "controller_helpers/tab_keys";

export function unscopedCollectionShown(model){
  return model.app[collectionShownName(model)].pwPipe(_.values);
};

export function scopedByRouteAndTab(model, tabKey){
  return unscopedCollectionShown(model).filter((record) => {
    return matchesRoute(record, model) &&
      matchesTab(record, model, tabKey);
  });
};

export const matchesRoute = (record, model) => {
  if (matchedRoute(model) === "/specialties/:id"){
    return _.includes(record.specializationIds, parseInt(matchedRouteParams(model).id));
  }
  else if (matchedRoute(model) === "/procedures/:id"){
    return _.includes(record.procedureIds, parseInt(matchedRouteParams(model).id))
  }
  else if (matchedRoute(model) === "/content_categories/:id"){
    return _.includes(recordShown(model).subtreeIds, record.categoryId);
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
