import _ from "lodash";
import contentCategoryItems from "controller_helpers/content_category_items";
import { selectedTabKey, tabKey, isTabbedPage } from "controller_helpers/tab_keys";
import { NavTabs, NavTab } from "component_helpers/nav_tabs";
import { tabClicked } from "action_creators";
import { route } from "controller_helpers/routing";
import React from "react";
import recordShownByBreadcrumb from "controller_helpers/record_shown_by_breadcrumb";
import { encode } from "utils/url_hash_encoding";


const NavTabsController = ({model, dispatch}) => {
  if (isTabbedPage(model)) {
    if(route === "/hospitals/:id") {
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
    else if (route === "/news_items"){
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
    else if (_.includes(["/change_requests", "/issues"], route)) {
      return(
        <NavTabs>
          <NavTabController
            label="Pending"
            tabKey="pendingIssues"
            model={model}
            dispatch={dispatch}
          />
          <NavTabController
            label="Closed"
            tabKey="closedIssues"
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
  if (_.includes(["/specialists/:id", "/clinics/:id", "/content_items/:id"],
    route)){
    return(
      <NavTab
        label={label}
        doesPageNav={true}
        href={pageNavHref(model, tabKey)}
        isSelected={tabKey === selectedTabKey(model)}
      />
    )
  }
  else {
    return(
      <NavTab
        label={label}
        doesPageNav={false}
        onClick={_.partial(tabClicked, dispatch, model, tabKey)}
        isSelected={tabKey === selectedTabKey(model)}
      />
    );
  }
}

const pageNavHref = (model, tabKey) => {
  return (`/specialties/${recordShownByBreadcrumb(model).id}#` +
    encode({selectedTabKey: tabKey}))
}


const contentCategoryTabs = (model, dispatch) => {
  if(route === "/languages/:id"){
    return []
  }
  else {
    return(
      _.values(contentCategoriesShowingTabs(model)).
        sort((category) => category.name === "Virtual Consult" ? 0 : 1).
        map((category) => {

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
