import React from "react";
import { sortByHeading } from "action_creators";

const TableRows = (model, dispatch) => {
  return sortedRecordsToDisplay(model).map((record) => {
    return(
      <tr key={record.id}>
        <td key="name"><a href={`/users/${record.id}`}>{record.name}</a></td>
        <td key="views">{record.pageViews}</td>
      </tr>
    );
  })
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
    var sortByKey = "pageViews";
    var order = matchingSortOrder(model);
  }
  else {
    var sortByKey = "name";
    var order = reverseSortOrder(model);
  }

  return _.sortByOrder(
    model.ui.recordsToDisplay,
    [ _.property(sortByKey) ],
    [ order]
  );

}

const isTableLoaded = (model) => {
  return model.ui.recordsToDisplay;
}

const TableController = ({model, dispatch}) => {
  if (isTableLoaded(model)){
    return (
      <table className="table">
        <thead>
          <tr>
            <TableHeadingController
              model={model}
              dispatch={dispatch}
              label={"User"}
              key={"USER"}
              headingKey={"USER"}
            />
            <TableHeadingController
              model={model}
              dispatch={dispatch}
              label={"Page Views"}
              key={"PAGE_VIEWS"}
              headingKey={"PAGE_VIEWS"}
            />
          </tr>
        </thead>
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

const TableHeadingController = ({model, dispatch, label, headingKey}) => {
  const onClick = _.partial(
    sortByHeading,
    dispatch,
    headingKey,
    selectedTableHeadingKey(model)
  );

  return(
    <th onClick={onClick}>
      <span>{ label }</span>
      <TableHeadingArrowController
        model={model}
        headingKey={headingKey}
      />
    </th>
  );
}

const TableHeadingArrowController = ({model, headingKey}) => {
  if (selectedTableHeadingKey(model) === headingKey) {
    return(
      <i className={`icon-arrow-${tableSortDirection(model).toLowerCase()}`}
        style={{color: "#08c", marginLeft: "5px"}}
      />
    );
  }
  else {
    return(<span></span>)
  }
}

const selectedTableHeadingKey = (model) => {
  return _.get(model, ["ui", "selectedTableHeading", "key"], "PAGE_VIEWS")
}

const tableSortDirection = (model) => {
  return _.get(model, ["ui", "selectedTableHeading", "direction"], "DOWN");
}

export default TableController;
