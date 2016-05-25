import React from "react";

const TableRow = ({model, dispatch, record}) => {
  return(
    <tr key={record.id}>
      <td key="name"><a href={`/users/${record.id}`}>{record.name}</a></td>
      <td key="views">{record.pageViews}</td>
    </tr>
  );
};

export default TableRow;
