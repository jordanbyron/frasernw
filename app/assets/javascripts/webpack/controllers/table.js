import React from "react";
import { matchedRoute } from "controller_helpers/routing";
import TableRows from "controllers/table_rows";
import TableHeading from "controllers/table_heading";

const isTableLoaded = (model) => {
  return model.ui.recordsToDisplay;
}

const Table = ({model, dispatch}) => {
  if (matchedRoute(model) === "/reports/pageviews_by_user" && isTableLoaded(model)){
    return (
      <table className="table">
        <TableHeading model={model} dispatch={dispatch}/>
        <tbody>
          { TableRows(model, dispatch) }
        </tbody>
      </table>
    );
  }
  else {
    return(<span></span>);
  }
}

export default Table;
