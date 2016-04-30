import React from "react";
import { sortByHeading } from "action_creators";

const TableRows = (model, dispatch) => {
  return model.ui.recordsToDisplay.map((record) => {
    return(
      <tr key={record.id}>
        <td key="name"><a href={`/users/${record.id}`}>{record.name}</a></td>
        <td key="views">{record.pageViews}</td>
      </tr>
    );
  })
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
  return(
    <th onClick={_.partial(sortByHeading, dispatch, headingKey)}>
      <span>{ label }</span>
      <TableHeadingArrowController
        model={model}
        headingKey={headingKey}
      />
    </th>
  )
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
  return model.ui.selectedTableHeading.key || "PAGE_VIEWS";
}

const tableSortDirection = (model) => {
  return model.ui.selectedTableHeading.direction || "DOWN";
}

export default TableController;
