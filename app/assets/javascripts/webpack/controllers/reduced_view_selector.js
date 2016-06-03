import React from "react";
import { selectReducedView } from "action_creators";
import reducedView from "controller_helpers/reduced_view";
import { buttonIsh } from "stylesets";

const ReducedViewSelector = ({model, dispatch}) => {
  const newView = {
    main: "sidebar",
    sidebar: "main"
  }[reducedView(model)];

  const label = {
    main: "Show Filters",
    sidebar: "Show Table"
  }[reducedView(model)];

  return(
    <div className="row">
      <div className="toggle-filters visible-phone">
        <a onClick={_.partial(selectReducedView, dispatch, newView)}
          style={buttonIsh}>
          <i className="icon-blue icon-cog icon-small"></i>
          <span style={{marginLeft: "3px"}}>{ label }</span>
        </a>
      </div>
    </div>
  );
}

export default ReducedViewSelector;
