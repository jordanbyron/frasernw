import React from "react";
import Table from "controllers/table";
import * as FilterValues from "controller_helpers/filter_values";
import { changeFilterValue } from "action_creators";
import { padTwo } from "utils";
import DateRangeFilter from "controllers/filter_groups/date_range";
import DivisionScopeFilter from "controllers/filter_groups/division_scope";
import { matchedRoute } from "controller_helpers/routing";
import Breadcrumbs from "controllers/breadcrumbs";
import NavTabs from "controllers/nav_tabs";
import ReducedViewSelector from "controllers/reduced_view_selector";
import reducedView from "controller_helpers/reduced_view";

const TemplateController = ({model, dispatch}) => {
  if(model.app.currentUser) {
    return(
      <div>
        <Breadcrumbs model={model} dispatch={dispatch}/>
        <NavTabs model={model} dispatch={dispatch}/>
        <WhitePanel model={model} dispatch={dispatch}/>
      </div>
    );
  }
  else {
    return(<span></span>);
  }
};


const usesSidebarLayout = (model) => {
  return matchedRoute(model) !== "/latest_updates" ||
    model.app.currentUser.isAdmin
}

const WhitePanel = ({model, dispatch}) => {
  if (usesSidebarLayout(model)){
    return(
      <div className="content-wrapper">
        <div className="content">
          <ReducedViewSelector model={model} dispatch={dispatch}/>
          <div className="row">
            <div className={`span8half ${viewSelectorClass(model, "main")}`}>
              <div>This is the main panel</div>
              <PageTitle model={model} dispatch={dispatch}/>
              <Table model={model} dispatch={dispatch}/>
            </div>
            <Sidebar model={model} dispatch={dispatch}/>
          </div>
        </div>
      </div>
    );
  } else {
    return(
      <div className="content-wrapper">
        <div className="content">
          <div className="row">
            <div className="span12">
              { "whatever" }
            </div>
          </div>
        </div>
      </div>
    );
  }
};

const viewSelectorClass = (model, view) => {
  if (reducedView(model) === view){
    return "";
  }
  else {
    return "hide-when-reduced";
  }
}

const PageTitle = ({model, dispatch}) => {
  if (matchedRoute(model) === "/reports/pageviews_by_user") {
    return(
      <h2 style={{marginBottom: "10px"}}>
        { "Page Views by User" }
      </h2>
    );
  }
  else {
    return <span></span>
  }
};

const Sidebar = ({model, dispatch}) => {
  if (matchedRoute(model) === "/reports/pageviews_by_user") {
    return(
      <div className={
        `span3 offsethalf datatable-sidebar ${viewSelectorClass(model, "sidebar")}`
      }>
        <div className="well filter">
          <div className="title">{ "Configure Report" }</div>
          <DateRangeFilter model={model} dispatch={dispatch}/>
          <DivisionScopeFilter model={model} dispatch={dispatch}/>
        </div>
      </div>
    );
  }
  else {
    return(
      <div className={
        `span3 offsethalf datatable-sidebar ${viewSelectorClass(model, "sidebar")}`
      }>This is the sidebar</div>
    );
  }
};

export default TemplateController;
