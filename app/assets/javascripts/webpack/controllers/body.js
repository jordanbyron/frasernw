import NavTabsController from "controllers/nav_tabs";
import React from "react";
import {
  SidebarLayout,
  SidebarLayoutMainSection,
  SidebarLayoutSideSection,
  SidebarLayoutReducedViewSelector
} from "helpers/sidebar_layout";
import { reducedViewSelectorClicked } from "actions"

const BodyController = ({model, dispatch}) => {
  return(
    <div>
      <NavTabsController model={model} dispatch={dispatch}/>
      <div className="content-wrapper">
        <SidebarLayoutReducedViewSelector
          onClick={_.partial(reducedViewSelectorClicked, dispatch, reducedView(model))}
          text={reducedViewSelectorText(model)}
        />
        <SidebarLayout>
          <SidebarLayoutMainSection reducedView={reducedView(model)}>
            { "main" }
          </SidebarLayoutMainSection>
          <SidebarLayoutSideSection reducedView={reducedView(model)}>
            { "side" }
          </SidebarLayoutSideSection>
        </SidebarLayout>
      </div>
    </div>
  )
};

const reducedViewSelectorText = (model) => {
  return({
    main: "Show Filters",
    sidebar: "Show Table"
  }[reducedView(model)]);
};

const reducedView = (model) => {
  return model.ui.reducedView || "main";
}

export default BodyController;
