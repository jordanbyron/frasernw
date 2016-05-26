import React from "react";
import TableRow from "controllers/table_row";
import { selectedTableHeadingKey, tableSortDirection }
  from "controller_helpers/sorting";

const TableRows = (model, dispatch) => {
  // TODO

  return [];
  // return sortedRecordsToDisplay(model).map((record) => {
  //   return(
  //     <TableRow
  //       key={record.id}
  //       model={model}
  //       dispatch={dispatch}
  //       record={record}
  //     />
  //   );
  // })
}

const reverseSortOrder = (model) => {
  if (tableSortDirection(model) === "UP"){
    return "desc";
  }
  else {
    return "asc";
  }
}

const matchingSortOrder = (model) => {
  if (tableSortDirection(model) === "UP"){
    return "asc";
  }
  else {
    return "desc";
  }
}

const sortedRecordsToDisplay = (model) => {
  if (selectedTableHeadingKey(model) === "PAGE_VIEWS"){
    var iteratee = _.property("pageViews");
    var order = matchingSortOrder(model);
  }
  else {
    var iteratee = _.property("name").pwPipe(_.trimLeft);
    var order = reverseSortOrder(model);
  }

  return _.sortByOrder(
    model.ui.recordsToDisplay,
    [ iteratee ],
    [ order]
  );
}

export default TableRows;
