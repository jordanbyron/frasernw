import _ from "lodash";
import contentCategoryItems from "controller_helpers/content_category_items";
import { selectedTabKey, tabKey, isTabbedPage } from "controller_helpers/tab_keys";
import { NavTabs, NavTab } from "component_helpers/nav_tabs";
import { tabClicked } from "action_creators";
import { matchedRoute } from "controller_helpers/routing";
import { memoize } from "utils";
import React from "react";

const NavTabsController = ({model, dispatch}) => {
  if (isTabbedPage(model)) {
    if(matchedRoute(model) === "/hospitals/:id") {
      return(
        <NavTabs>
          <NavTabController
            label="Specialists with Hospital Privileges"
            tabKey="specialistsWithPrivileges"
            model={model}
            dispatch={dispatch}
          />
          <NavTabController
            label="Clinics in Hospital"
            tabKey="clinicsIn"
            model={model}
            dispatch={dispatch}
          />
          <NavTabController
            label="Specialists with Offices in Hospital"
            tabKey="specialistsWithOffices"
            model={model}
            dispatch={dispatch}
          />
        </NavTabs>
      );
    }
    else if (matchedRoute(model) === "/news_items"){
      return(
        <NavTabs>
          <NavTabController
            label="Owned (editable)"
            tabKey="ownedNewsItems"
            model={model}
            dispatch={dispatch}
          />
          <NavTabController
            label="Currently Showing"
            tabKey="showingNewsItems"
            model={model}
            dispatch={dispatch}
          />
          <NavTabController
            label="Available from Other Divisions"
            tabKey="availableNewsItems"
            model={model}
            dispatch={dispatch}
          />
        </NavTabs>
      );
    }
    else if (_.includes(["/change_requests", "/issues"], matchedRoute(model))) {
      return(
        <NavTabs>
          <NavTabController
            label="Pending"
            tabKey="pendingIssues"
            model={model}
            dispatch={dispatch}
          />
          <NavTabController
            label="Completed"
            tabKey="completedIssues"
            model={model}
            dispatch={dispatch}
          />
        </NavTabs>
      );
    }
    else {
      return(
        <NavTabs>
          <NavTabController
            label="Specialists"
            tabKey="specialists"
            model={model}
            dispatch={dispatch}
          />
          <NavTabController
            label="Clinics"
            tabKey="clinics"
            model={model}
            dispatch={dispatch}
          />
          {contentCategoryTabs(model, dispatch)}
        </NavTabs>
      );
    }
  }
  else {
    return <span></span>;
  }
};

const NavTabController = ({model, dispatch, tabKey, label}) => {
  return(
    <NavTab
      label={label}
      onClick={_.partial(tabClicked, dispatch, model, tabKey)}
      isSelected={tabKey === selectedTabKey(model)}
    />
  );
}


const contentCategoryTabs = (model, dispatch) => {
  if(matchedRoute(model) === "/languages/:id"){
    return []
  }
  else {
    return(
      _.values(contentCategoriesShowingTabs(model)).map((category) => {
        const _key = tabKey("contentCategory", category.id)
        return(
          <NavTabController
            label={category.name}
            tabKey={_key}
            key={_key}
            model={model}
            dispatch={dispatch}
          />
        );
      })
    );
  }
}

const contentCategoriesShowingTabs = (model) => {
  return _.filter(
    model.app.contentCategories,
    (category) => {
      return (
        [1, 3, 4, 5].indexOf(category.displayMask) > -1 &&
        category.ancestry == null &&
        contentCategoryItems(
          category.id,
          model
        ).pwPipe(_.keys).pwPipe(_.some)
      );
    }
  );
};

export default NavTabsController;
