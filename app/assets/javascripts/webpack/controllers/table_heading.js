import React from "react";
import { selectedTableHeadingKey, tableSortDirection }
  from "controller_helpers/sorting";
  import { sortByHeading } from "action_creators";


const TableHeadingCell = ({model, dispatch, label, headingKey}) => {
  const onClick = _.partial(
    sortByHeading,
    dispatch,
    headingKey,
    selectedTableHeadingKey(model)
  );

  return(
    <th onClick={onClick} className="datatable__heading">
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

const TableHeading = ({model, dispatch}) => {
  return(
    <thead>
      <tr>
        <TableHeadingCell
          model={model}
          dispatch={dispatch}
          label={"User"}
          key={"USER"}
          headingKey={"USER"}
        />
        <TableHeadingCell
          model={model}
          dispatch={dispatch}
          label={"Page Views"}
          key={"PAGE_VIEWS"}
          headingKey={"PAGE_VIEWS"}
        />
      </tr>
    </thead>
  );
}

export default TableHeading;
