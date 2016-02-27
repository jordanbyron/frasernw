import _ from "lodash";
import React from "react";
import PlaceHolder from "helpers/placeholder";

const ForRoutes = ({model, dispatch, klass, supportedRoutes}) => {
  if (_.includes(supportedRoutes, model.ui.location.route)) {
    return React.createElement(klass, { model: model, dispatch: dispatch });
  } else {
    return <PlaceHolder/>;
  }
}

export default ForRoutes;
