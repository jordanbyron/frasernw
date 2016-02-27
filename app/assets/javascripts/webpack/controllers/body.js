import NavTabsController from "controllers/nav_tabs";
import React from "react";

const BodyController = ({model, dispatch}) => {
  return(
    <div>
      <NavTabsController model={model} dispatch={dispatch}/>
    </div>
  )
}

export default BodyController;
