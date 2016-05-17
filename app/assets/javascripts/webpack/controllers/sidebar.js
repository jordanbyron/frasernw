import React from "react";
import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import { viewSelectorClass }  from "controller_helpers/reduced_view";
import { recordShownByPanel, selectedPanelKey } from "controller_helpers/panel_keys";
import DateRangeFilters from "controllers/filter_groups/date_range";
import DivisionScopeFilters from "controllers/filter_groups/division_scope";
import ProcedureFilters from "controllers/filter_groups/procedure";

const pageIsReport = (model) => {
  return matchedRoute(model).includes("/reports/");
};

const collectionShownPluralLabel = (model) => {
  switch(collectionShown(model)){
  case "specialists":
    if (matchedRoute(model) === "/specialties/:id"){
      return recordShownByPage(model).membersName;
    } else {
      return "Specialists"
    }
  case "clinics":
    if (matchedRoute(model) === "/specialties/:id"){
      return `${recordShownByPage(model)} Clinics`;
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

const collectionShown = (model) => {
  if(_.includes(["specialists", "clinics"], selectedPanelKey(model))){
    return selectedPanelKey(model);
  }
  else if (selectedPanelKey(model).includes("contentCategory")){
    return "contentItems";
  }
};

const sidebarTitle = (model) => {
  if (pageIsReport(model)) {
    return "Configure Report";
  }
  else if (matchedRoute(model) === "/latest_updates"){
    return "Admin-Only Options";
  }
  else {
    return `Filter ${collectionShownPluralLabel(model)}`;
  }
}

const Sidebar = ({model, dispatch}) => {
  return(
    <div className={
      `span3 offsethalf datatable-sidebar ${viewSelectorClass(model, "sidebar")}`
    }>
      <div className="well filter">
        <div className="title">{ sidebarTitle(model) }</div>
        <ProcedureFilters model={model} dispatch={dispatch}/>
        <DateRangeFilters model={model} dispatch={dispatch}/>
        <DivisionScopeFilters model={model} dispatch={dispatch}/>
      </div>
    </div>
  );
};

export default Sidebar;
