import _ from "lodash";
import {
  selectedTabKey, tabKey, isTabbedPage, navTabKeys
} from "controller_helpers/nav_tab_keys";
import { NavTabs, NavTab } from "component_helpers/nav_tabs";
import { tabClicked } from "action_creators";
import { route } from "controller_helpers/routing";
import React from "react";
import recordShownByBreadcrumb from "controller_helpers/record_shown_by_breadcrumb";
import { encode } from "utils/url_hash_encoding";
import { navTabKeyId, recordShownByTabKey } from "controller_helpers/nav_tab_key";

const NavTabsController = ({model, dispatch}) => {
  if (isTabbedPage(model)) {
    return(
      <NavTabs>
        {
          navTabKeys(model).map((tabKey) => {
            return(
              <NavTabController
                label={label(tabKey)}
                tabKey={tabKey}
                model={model}
                dispatch={dispatch}
                key={tabKey}
              />
            );
          })
        }
      </NavTabs>
    )
  }
  else {
    return <span></span>
  }
}

const label = (navTabKey) => {
  if (navTabKeyId(navTabKey) === null){
    switch(navTabKey){
    case "closedIssues": return "Closed";
    case "pendingIssues": return "Pending";
    case "specialistsWithPrivileges": return "Specialists with Hospital Privileges";
    case "availableNewsItems": return "Available from Other Divisions";
    case "showingNewsItems": return "Currently Showing";
    case "ownedNewsItems": return "Owned (editable)";
    case "specialistsWithOffices": return "Specialists with Offices in Hospital";
    case "clinicsIn": return "Clinics in Hospital";
    case "specialistsWithPrivileges": return "Specialists with Hospital Privileges";
    case "specialists": return "Specialists";
    case "clinics": return "Clinics";
    }
  }
  else {
    return recordShownByTabKey(navTabKey).name;
  }
}

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

export default NavTabsController;
