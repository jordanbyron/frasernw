import React from "react"
import { areRowsExpanded } from "controller_helpers/table_row_expansion";
import { toggleRowExpansion } from "action_creators";


const ExpandRowsToggle = ({model, dispatch, shouldShow}) => {
  if(shouldShow) {
    return(
      <div className="btn btn-default btn-small"
        style={{marginLeft: "7px", padding: "2px 5px", verticalAlign: "bottom", fontSize: "12px"}}
        onClick={_.partial(toggleRowExpansion, model, dispatch, !areRowsExpanded(model))}>
        { icon(model) }
      </div>
    )
  }
  else {
    return <noscript/>;
  }
}

const icon = (model) => {
  if (areRowsExpanded(model)){
    return "-";
  }
  else {
    return "+";
  }
}

export default ExpandRowsToggle;
