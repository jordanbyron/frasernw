import React from "react";
import TableController from "controllers/table";
import * as FilterValues from "controller_helpers/filter_values";
import { changeFilterValue } from "action_creators";
import { padTwo } from "utils";
import DateRangeFilterController from "controllers/filter_groups/date_range";
import DivisionScopeFilterController from "controllers/filter_groups/division_scope";
import { matchedRoute } from "controller_helpers/routing";
import BreadcrumbsController from "controllers/breadcrumbs";




const TemplateController = ({model, dispatch}) => {
  return(
    <div>
      <BreadcrumbsController model={model} dispatch={dispatch}/>
      <div className="content-wrapper">
        <div className="content">
          <div className="row">
            <div className="span8half">
              <h2 style={{marginBottom: "10px"}}>
                { "Page Views by User" }
              </h2>
              <TableController model={model} dispatch={dispatch}/>
            </div>
            <SidebarController model={model} dispatch={dispatch}/>
          </div>
        </div>
      </div>
    </div>
  );
};


const SidebarController = ({model, dispatch}) => {
  if(model.app.currentUser) {
    return(
      <div className="span3 offsethalf datatable-sidebar hide-when-reduced">
        <div className="well filter">
          <div className="title">{ "Configure Report" }</div>
          <DateRangeFilterController model={model} dispatch={dispatch}/>
          <DivisionScopeFilterController model={model} dispatch={dispatch}/>
        </div>
      </div>
    );
  }
  else {
    return(<span></span>);
  }
}

export default TemplateController;
