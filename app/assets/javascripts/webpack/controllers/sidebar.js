import React from "react";
import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import { viewSelectorClass }  from "controller_helpers/reduced_view";
import { recordShownByTab, selectedTabKey} from "controller_helpers/tab_keys";
import { collectionShownName } from "controller_helpers/collection_shown";
import DateRangeFilters from "controllers/filter_groups/date_range";
import DivisionScopeFilters from "controllers/filter_groups/division_scope";
import ProcedureFilters from "controllers/filter_groups/procedures";
import ReferralsFilters from "controllers/filter_groups/referrals";
import SexFilters from "controllers/filter_groups/sex";
import ScheduleFilters from "controllers/filter_groups/schedule";
import CareProviderFilters from "controllers/filter_groups/care_providers";
import TeleserviceFilters from "controllers/filter_groups/teleservices";
import LanguagesFilters from "controllers/filter_groups/languages";
import AssociationsFilters from "controllers/filter_groups/associations";
import CityFilters from "controllers/filter_groups/cities";
import ClinicDetailsFilters from "controllers/filter_groups/clinic_details";
import SubcategoriesFilters from "controllers/filter_groups/subcategories";
import SpecializationsFilters from "controllers/filter_groups/specializations";
import HiddenUpdatesFilter from "controllers/filter_groups/hidden_updates";
import EntityTypeFilters from "controllers/filter_groups/entity_type";
import MonthFilter from "controllers/filter_groups/month";

const pageIsReport = (model) => {
  return matchedRoute(model).includes("/reports/");
};

const collectionShownPluralLabel = (model) => {
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
        <ClinicDetailsFilters model={model} dispatch={dispatch}/>
        <ReferralsFilters model={model} dispatch={dispatch}/>
        <DateRangeFilters model={model} dispatch={dispatch}/>
        <EntityTypeFilters model={model} dispatch={dispatch}/>
        <DivisionScopeFilters model={model} dispatch={dispatch}/>
        <SexFilters model={model} dispatch={dispatch}/>
        <ScheduleFilters model={model} dispatch={dispatch}/>
        <TeleserviceFilters model={model} dispatch={dispatch}/>
        <CareProviderFilters model={model} dispatch={dispatch}/>
        <LanguagesFilters model={model} dispatch={dispatch}/>
        <AssociationsFilters model={model} dispatch={dispatch}/>
        <CityFilters model={model} dispatch={dispatch}/>
        <SubcategoriesFilters model={model} dispatch={dispatch}/>
        <SpecializationsFilters model={model} dispatch={dispatch}/>
        <HiddenUpdatesFilter model={model} dispatch={dispatch}/>
        <MonthFilter model={model} dispatch={dispatch}/>
      </div>
    </div>
  );
};

export default Sidebar;
