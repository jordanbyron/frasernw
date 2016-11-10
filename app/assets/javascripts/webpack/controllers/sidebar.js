import React from "react";
import { route, recordShownByRoute } from "controller_helpers/routing";
import { viewSelectorClass }  from "controller_helpers/reduced_view";
import { recordShownByTab, selectedTabKey} from "controller_helpers/nav_tab_keys";
import { collectionShownName, collectionShownPluralLabel }
  from "controller_helpers/collection_shown";
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
import ReportStyleFilter from "controllers/filter_groups/report_style";
import CompletionDateFilter from "controllers/filter_groups/completion_date";
import AssigneesFilter from "controllers/filter_groups/assignees";
import IssueSourceFilter from "controllers/filter_groups/issue_source";
import PriorityFilter from "controllers/filter_groups/priority";
import SidebarAnnotation from "controllers/sidebar_annotation";

const pageIsReport = (model) => {
  return route.includes("/reports/");
};

const sidebarTitle = (model) => {
  if (pageIsReport(model)) {
    return "Configure Report";
  }
  else if (route === "/latest_updates"){
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
        <SubcategoriesFilters model={model} dispatch={dispatch}/>
        <ProcedureFilters model={model} dispatch={dispatch}/>
        <SpecializationsFilters model={model} dispatch={dispatch}/>
        <ReferralsFilters model={model} dispatch={dispatch}/>
        <ClinicDetailsFilters model={model} dispatch={dispatch}/>
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
        <HiddenUpdatesFilter model={model} dispatch={dispatch}/>
        <ReportStyleFilter model={model} dispatch={dispatch}/>
        <CompletionDateFilter model={model} dispatch={dispatch}/>
        <AssigneesFilter model={model} dispatch={dispatch}/>
        <IssueSourceFilter model={model} dispatch={dispatch}/>
        <PriorityFilter model={model} dispatch={dispatch}/>
      </div>
      <SidebarAnnotation model={model}/>
    </div>
  );
};

export default Sidebar;
