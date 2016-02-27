import _ from "lodash";
import React from "react";
import PlaceHolder from "helpers/placeholder";

const ByRoute = ({model, dispatch, routeHandlers}) => {
  const matchedHandler = _.find(routeHandlers, (handler, routeHandled) => {
    return model.ui.location.route === routeHandled;
  });

  if (matchedHandler === undefined) {
    return <PlaceHolder/>;
  } else {
    return React.createElement(matchedHandler, { model: model, dispatch: dispatch });
  }
}

export default ByRoute;
