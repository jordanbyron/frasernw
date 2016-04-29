import React from "react";

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
            <th>User</th>
            <th>Page Views</th>
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

export default TableController;
