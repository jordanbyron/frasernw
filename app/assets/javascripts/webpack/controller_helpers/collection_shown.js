import { matchedRoute, matchedRouteParams, recordShownByRoute }
  from "controller_helpers/routing";
import { selectedTabKey, recordShownByTab } from "controller_helpers/tab_keys";
import { memoizePerRender } from "utils";
import { isTabbedPage } from "controller_helpers/tab_keys";
import * as filterValues from "controller_helpers/filter_values";
import recordShownByBreadcrumb from "controller_helpers/record_shown_by_breadcrumb";
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
    else if (matchedRoute(model) === "/issues") {
      return "issues";
    }
    else if (matchedRoute(model) === "/change_requests") {
      return "changeRequests";
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
    return matchesPage(record, model) &&
      (!isTabbedPage(model) || matchesTab(record, model, selectedTabKey(model)));
  });
}).pwPipe(memoizePerRender)

export const matchesPage = (record, model) => {
  switch(matchedRoute(model)){
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
      recordShownByRoute(model).assumedSpecializationId
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
  case "/specialists/:id":
    return _.includes(
      record.specializationIds,
      recordShownByBreadcrumb(model).id
    )
  case "/clinics/:id":
    return _.includes(
      record.specializationIds,
      recordShownByBreadcrumb(model).id
    )
  case "/content_items/:id":
    return _.includes(
      record.specializationIds,
      recordShownByBreadcrumb(model).id
    )
  default:
    return true;
  }
};

export const matchesTab = (record, model, tabKey) => {
  if (tabKey === "specialistsWithPrivileges"){
    return _.includes(record.hospitalIds, recordShownByRoute(model).id)
  }
  else if (tabKey === "clinicsIn"){
    return _.includes(record.hospitalsInIds, recordShownByRoute(model).id)
  }
  else if (tabKey === "specialistsWithOffices") {
    return _.includes(record.hospitalsWithOfficesInIds, recordShownByRoute(model).id);
  }
  else if (_.includes(["specialists", "clinics"], tabKey)){
    return true;
  }
  else if (tabKey.includes("contentCategory")){
    let contentCategory =
      model.app.contentCategories[tabKey.replace("contentCategory", "")]

    return _.includes(
      contentCategory.subtreeIds,
      record.categoryId
    );
  }
  else if (tabKey === "ownedNewsItems"){
    return staticDivisionalScope(model).id === record.ownerDivisionId;
  }
  else if (tabKey === "showingNewsItems"){
    return record.isCurrent &&
      _.includes(record.divisionDisplayIds, staticDivisionalScope(model).id)
  }
  else if (tabKey === "availableNewsItems"){
    return staticDivisionalScope(model).id !== record.ownerDivisionId
  }
  else if (tabKey === "pendingIssues"){
    return !_.includes([4, 7], record.progressKey);
  }
  else if (tabKey === "closedIssues"){
    return _.includes([4, 7], record.progressKey);
  }
};

const staticDivisionalScope = (model) => {
  return model.app.divisions[model.ui.persistentConfig.divisionId];
}

export const collectionShownPluralLabel = ((model) => {
  switch(collectionShownName(model)){
  case "specialists":
    if (matchedRoute(model) === "/specialties/:id"){
      return recordShownByRoute(model).membersName;
    } else {
      return "Specialists"
    }
  case "clinics":
    if (matchedRoute(model) === "/specialties/:id"){
      return `${recordShownByRoute(model).name} Clinics`;
    } else {
      return "Clinics"
    }
  case "contentItems":
    if (matchedRoute(model) === "/content_categories/:id") {
      return recordShownByRoute(model).name;
    }
    else {
      return recordShownByTab(model).name;
    }
  default:
    return _.capitalize(collectionShownName(model));
  }
}).pwPipe(memoizePerRender);
