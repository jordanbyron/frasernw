import React from "react"
import { areRowsExpanded } from "controller_helpers/table_row_expansion";
import { toggleRowExpansion } from "action_creators";


const ExpandRowsToggle = ({model, dispatch, shouldShow}) => {
  if(shouldShow) {
    return(
      <div className="btn btn-default btn-small"
        style={{padding: "2px 5px", marginLeft: "7px", verticalAlign: "bottom", fontSize: "12px", marginBottom: "-1px"}}
        onClick={_.partial(toggleRowExpansion, model, dispatch, !areRowsExpanded(model))}>
        { label(model) }
      </div>
    )
  }
  else {
    return <noscript/>;
  }
}

const label = (model) => {
  if (areRowsExpanded(model)){
    return "Collapse";
  }
  else {
    return "Expand";
  }
}

export default ExpandRowsToggle;
