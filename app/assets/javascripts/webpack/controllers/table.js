import React from "react";
import { route, recordShownByRoute } from "controller_helpers/routing";
import TableRows from "controllers/table_rows";
import TableHeadings from "controllers/table_headings";
import { reportStyle } from "controller_helpers/filter_values";
import { recordShownByTab, isTabbedPage } from "controller_helpers/nav_tab_keys";
import { collectionShownName } from "controller_helpers/collection_shown";
import isDataDubious from "controller_helpers/dubious_data";

const Table = ({model, dispatch}) => {
  if (shouldShow(model)){
    if (isTableLoaded(model)){
      return (
        <table className="table">
          <TableHeadings model={model} dispatch={dispatch}/>
          <tbody>
            { TableRows(model, dispatch) }
          </tbody>
        </table>
      );
    }
    else {
      return <div style={{marginTop: "10px", marginBottom: "10px"}}>Loading...</div>;
    }

  }
  else {
    return(<span></span>);
  }
}

const shouldShow = (model) => {
  if (!_.includes(ROUTES_IMPLEMENTING, route)){
    return false;
  }

  if (isTabbedPage(model) &&
    collectionShownName(model) === "contentItems" &&
    !(recordShownByTab(model).componentType === "FilterTable")) {

    return false;
  }

  if (route === "/content_categories/:id" &&
    !(recordShownByRoute(model).componentType === "FilterTable")) {

    return false;
  }

  if (route === "/reports/profiles_by_specialty" &&
    (reportStyle(model) === "expanded")) {

    return false;
  }

  return true;
}

const isTableLoaded = (model) => {
  if(route === "/reports/page_views_by_user" ||
    route === "/reports/entity_page_views"){
    return model.ui.recordsToDisplay;
  }
  else {
    return true
  }
}

const ROUTES_IMPLEMENTING = [
  "/specialties/:id",
  "/areas_of_practice/:id",
  "/content_categories/:id",
  "/reports/page_views_by_user",
  "/reports/entity_page_views",
  "/reports/profiles_by_specialty",
  "/latest_updates",
  "/hospitals/:id",
  "/languages/:id",
  "/news_items",
  "/issues",
  "/change_requests"
];

export default Table;
