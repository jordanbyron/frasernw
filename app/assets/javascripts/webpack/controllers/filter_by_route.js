import _ from "lodash";
import React from "react";
import PlaceHolder from "helpers/placeholder";
import { route } from "selectors/routing";

const FilterByRoute = ({model, dispatch, handler, showingInRoutes}) => {
  if (_.includes(showingInRoutes, route(model))) {
    return React.createElement(handler, { model: model, dispatch: dispatch });
  } else {
    return <PlaceHolder/>;
  }
}

export default FilterByRoute;
