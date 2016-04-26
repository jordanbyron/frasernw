import React from "react";

const TableController = ({model, dispatch}) => {
  return (
    <table className="table">
      <thead>
        <tr>
          <th>User</th>
          <th>Page Views</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>Row 1</td>
          <td>Column 1</td>
        </tr>
      </tbody>
    </table>
  );
}

export default TableController;
