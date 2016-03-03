import NavTabsController from "controllers/nav_tabs";
import React from "react";
import { SidebarLayout, SidebarLayoutMainPanel, SidebarLayoutSidePanel } from "helpers/sidebar_layout";

const BodyController = ({model, dispatch}) => {
  return(
    <div>
      <NavTabsController model={model} dispatch={dispatch}/>
      <div className="content-wrapper">
        <SidebarLayout>
          <SidebarLayoutMainPanel sectionShowingWhenReduced={sectionShowingWhenReduced(model)}>
            { "main" }
          </SidebarLayoutMainPanel>
          <SidebarLayoutSidePanel sectionShowingWhenReduced={sectionShowingWhenReduced(model)}>
            { "side" }
          </SidebarLayoutSidePanel>
        </SidebarLayout>
      </div>
    </div>
  )
};

const sectionShowingWhenReduced = (model) => {
  return "sidebar";
}

export default BodyController;
