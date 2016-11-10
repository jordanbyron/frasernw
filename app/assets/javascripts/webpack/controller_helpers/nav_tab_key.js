import { recordShownByRoute } from "controller_helpers/routing";

export const navTabKey = (type, id) => {
  if (id) {
    return (type + id);
  } else {
    return type;
  }
};

export const navTabKeyId = (navTabKey) => {
  if (navTabKey.match(/\d+/)){
    return parseInt(navTabKey.match(/\d+/)[0]);
  }
  else {
    return null
  }
}

export const navTabKeyType = (navTabKey) => {
  return navTabKey.match(/[A-Za-z]+/)[0];
}

export const recordShownByTabKey = (model, navTabKey) => {
  if(navTabKeyId(navTabKey)){
    return model.app[pluralize(navTabKeyType(navTabKey))][navTabKeyId(navTabKey)];
  }
  else {
    return {};
  }
}

const pluralize = (tabType) => {
  return PLURALIZATIONS[tabType]
}

const PLURALIZATIONS = {
  contentCategory: "contentCategories"
}

export const matchesTabKey = (record, model, tabKey) => {
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
  else if (navTabKeyType(tabKey) === "contentCategory"){
    return _.includes(
      recordShownByTabKey(model, tabKey).subtreeIds,
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
