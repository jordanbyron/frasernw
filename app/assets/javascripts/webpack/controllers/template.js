import React from "react";
import TableController from "controllers/table";

const TemplateController = ({model, dispatch}) => {
  return(
    <div className="content-wrapper">
      <div className="content">
        <div className="row">
          <div className="span8half">
            <h2 style={{marginBottom: "10px"}}>
              { "Page Views by User" }
            </h2>
            <TableController model={model} dispatch={dispatch}/>
          </div>
          <div className="span3 offsethalf datatable-sidebar hide-when-reduced">
          </div>
        </div>
      </div>
    </div>
  );
}

export default TemplateController;
