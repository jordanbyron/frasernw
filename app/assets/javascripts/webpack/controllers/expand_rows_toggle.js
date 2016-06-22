import React from "react"
import { areRowsExpanded } from "controller_helpers/table_row_expansion";
import { toggleRowExpansion } from "action_creators";


const ExpandRowsToggle = ({model, dispatch, shouldShow}) => {
  if(shouldShow) {
    return(
      <div className="btn btn-default btn-small"
        style={{marginLeft: "7px", padding: "5px", verticalAlign: "bottom", lineHeight: "0px"}}
        onClick={_.partial(toggleRowExpansion, model, dispatch, !areRowsExpanded(model))}>
        <Icon model={model}/>
      </div>
    )
  }
  else {
    return <noscript/>;
  }
}

const Icon = ({model}) => {
  if (areRowsExpanded(model)){
    return(<i className="icon icon-minus icon-text"/>)
  }
  else {
    return(<i className="icon icon-plus icon-text"/>);
  }
}

export default ExpandRowsToggle;
