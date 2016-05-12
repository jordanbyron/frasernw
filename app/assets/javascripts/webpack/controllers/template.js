import React from "react";
import Table from "controllers/table";
import * as FilterValues from "controller_helpers/filter_values";
import { changeFilterValue } from "action_creators";
import { padTwo } from "utils";
import DateRangeFilter from "controllers/filter_groups/date_range";
import DivisionScopeFilter from "controllers/filter_groups/division_scope";
import { matchedRoute } from "controller_helpers/routing";
import Breadcrumbs from "controllers/breadcrumbs";


const TemplateController = ({model, dispatch}) => {
  if(model.app.currentUser) {
    return(
      <div>
        <Breadcrumbs model={model} dispatch={dispatch}/>
        <div className="content-wrapper">
          <div className="content">
            <div className="row">
              <div className="span8half">
                <h2 style={{marginBottom: "10px"}}>
                  { "Page Views by User" }
                </h2>
                <Table model={model} dispatch={dispatch}/>
              </div>
              <Sidebar model={model} dispatch={dispatch}/>
            </div>
          </div>
        </div>
      </div>
    );
  }
  else {
    return(<span></span>);
  }
};


const Sidebar = ({model, dispatch}) => {
  return(
    <div className="span3 offsethalf datatable-sidebar hide-when-reduced">
      <div className="well filter">
        <div className="title">{ "Configure Report" }</div>
        <DateRangeFilter model={model} dispatch={dispatch}/>
        <DivisionScopeFilter model={model} dispatch={dispatch}/>
      </div>
    </div>
  );
}

export default TemplateController;
