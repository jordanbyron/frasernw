import { matchedRoute, matchedRouteParams, recordShownByPage }
  from "controller_helpers/routing";
import { selectedTabKey, recordShownByTab } from "controller_helpers/tab_keys";
import { memoizePerRender } from "utils";
import { isTabbedPage } from "controller_helpers/tab_keys";
import * as filterValues from "controller_helpers/filter_values";
import _ from "lodash";

export const collectionShownName = ((model) => {
  if (isTabbedPage(model)){
    if (selectedTabKey(model).includes("specialists")) {
      return "specialists";
    }
    else if (selectedTabKey(model).includes("clinics")) {
      return "clinics";
    }
    else if (selectedTabKey(model).includes("contentCategory")){
      return "contentItems";
    }
    else if (matchedRoute(model) === "/news_items"){
      return "newsItems";
    }
  }
  else if (matchedRoute(model) === "/content_categories/:id"){
    return "contentItems";
  }
  else if (matchedRoute(model) === "/reports/referents_by_specialty"){
    if(filterValues.reportStyle(model) === "summary"){
      return "specializations";
    }
    else {
      return filterValues.entityType(model);
    }
  }
  else if (matchedRoute(model) === "/issues") {
    return "issues";
  }
}).pwPipe(memoizePerRender)

export const unscopedCollectionShown = ((model) => {
  if (matchedRoute(model) === "/latest_updates") {
    return model.ui.latestUpdates;
  }
  else {
    return model.app[collectionShownName(model)].pwPipe(_.values);
  }
}).pwPipe(memoizePerRender)

export const scopedByRouteAndTab = ((model) => {
  return unscopedCollectionShown(model).filter((record) => {
    return matchesRoute(
      matchedRoute(model),
      recordShownByPage(model),
      model.app.currentUser,
      record
    ) &&
      (!isTabbedPage(model) ||
        matchesTab(
          record,
          model.app.contentCategories,
          selectedTabKey(model),
          recordShownByPage(model)
        ));
  });
}).pwPipe(memoizePerRender)

export const matchesRoute = (matchedRoute, recordShownByPage, currentUser, record) => {
  switch(matchedRoute){
  case "/specialties/:id":
    return _.includes(
      record.specializationIds,
      recordShownByPage.id
    );
  case "/areas_of_practice/:id":
    return _.includes(
      record.procedureIds,
      recordShownByPage.id
    ) || _.intersection(
      record.specializationIds,
      recordShownByPage.assumedSpecializationId
    ).pwPipe(_.any);
  case "/content_categories/:id":
    return _.includes(
      recordShownByPage.subtreeIds,
      record.categoryId
    ) && _.intersection(
      record.availableToDivisionIds,
      currentUser.divisionIds
    ).pwPipe(_.any)
  case "/languages/:id":
    return _.includes(
      record.languageIds,
      recordShownByPage.id
    );
  default:
    return true;
  }
};

export const matchesTab = (record, contentCategories, tabKey, recordShownByPage) => {
  if (tabKey === "specialistsWithPrivileges"){
    return _.includes(record.hospitalIds, recordShownByPage.id)
  }
  else if (tabKey === "clinicsIn"){
    return _.includes(record.hospitalsInIds, recordShownByPage.id)
  }
  else if (tabKey === "specialistsWithOffices") {
    return _.includes(record.hospitalsWithOfficesInIds, recordShownByPage.id);
  }
  else if (_.includes(["specialists", "clinics"], tabKey)){
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
  else if (tabKey === "ownedNewsItems"){
    return recordShownByPage.id === record.ownerDivisionId;
  }
  else if (tabKey === "showingNewsItems"){
    return record.isCurrent &&
      _.includes(record.divisionDisplayIds, recordShownByPage.id)
  }
  else if (tabKey === "availableNewsItems"){
    return recordShownByPage.id !== record.ownerDivisionId
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
  default:
    return _.capitalize(collectionShownName(model));
  }
}).pwPipe(memoizePerRender);
