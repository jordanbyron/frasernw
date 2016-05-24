import React from "react";
import Table from "controllers/table";
import * as FilterValues from "controller_helpers/filter_values";
import { changeFilterValue } from "action_creators";
import { padTwo } from "utils";
import DateRangeFilters from "controllers/filter_groups/date_range";
import DivisionScopeFilters from "controllers/filter_groups/division_scope";
import { matchedRoute } from "controller_helpers/routing";
import Breadcrumbs from "controllers/breadcrumbs";
import NavTabs from "controllers/nav_tabs";
import ReducedViewSelector from "controllers/reduced_view_selector";
import { reducedView, viewSelectorClass } from "controller_helpers/reduced_view";
import Sidebar from "controllers/sidebar";
import { recordShownByTab } from "controller_helpers/tab_keys";
import { recordShownByPage } from "controller_helpers/routing";
import { isTabbedPage } from "controllers/nav_tabs";
import { collectionShownName } from "controller_helpers/collection_shown";

const Template = ({model, dispatch}) => {
  if(isLoaded(model)) {
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

const isLoaded = (model) => {
  return model.app.specialists && model.app.currentUser;
}

const showInlineArticles = (model) => {
  return collectionShownName(model) === "contentItems" &&
    ((isTabbedPage(model) &&
      recordShownByTab(model).componentType === "InlineArticles") ||
    (!isTabbedPage(model) &&
      recordShownBypage(model).componentType === "InlineArticles"))
};

const usesSidebarLayout = (model) => {
  return !((matchedRoute(model) === "/latest_updates" &&
    model.app.currentUser.isAdmin) ||
    showInlineArticles(model))
}

const WhitePanel = ({model, dispatch}) => {
  if (usesSidebarLayout(model)){
    return(
      <div className="content-wrapper">
        <div className="content">
          <ReducedViewSelector model={model} dispatch={dispatch}/>
          <div className="row">
            <Main model={model} dispatch={dispatch}/>
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

const Main = ({model, dispatch}) => {
  return(
    <div className={`span8half ${viewSelectorClass(model, "main")}`}>
      <div>This is the main panel</div>
      <PageTitle model={model} dispatch={dispatch}/>
      <Table model={model} dispatch={dispatch}/>
    </div>
  );
}

export default Template;
