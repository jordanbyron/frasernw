import _ from "lodash";
import contentCategoryItems from "controller_helpers/content_category_items";
import { selectedTabKey, tabKey } from "controller_helpers/tab_keys";
import { NavTabs, NavTab } from "component_helpers/nav_tabs";
import { tabClicked } from "action_creators";
import { matchedRoute } from "controller_helpers/routing";
import React from "react";

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

const contentCategoryTabs = (model, dispatch) => {
  return(
    _.values(contentCategoriesShowingTabs(model)).map((category) => {
      const _key = tabKey("contentCategory", category.id)
      return(
        <NavTab
          label={category.name}
          key={_key}
          onClick={_.partial(tabClicked, dispatch, model, _key)}
          isSelected={_key === selectedTabKey(model)}
        />
      );
    })
  );
}

const SHOWING_IN_ROUTES = [
  "/specialties/:id",
  "/areas_of_practice/:id"
];

const NavTabsController = ({model, dispatch}) => {
  if (_.includes(SHOWING_IN_ROUTES, matchedRoute(model))) {
    return(
      <NavTabs>
        <NavTab
          label="Specialists"
          key="specialists"
          onClick={_.partial(tabClicked, dispatch, model, "specialists")}
          isSelected={"specialists" === selectedTabKey(model)}
        />
        <NavTab
          label="Clinics"
          key="clinics"
          onClick={_.partial(tabClicked, dispatch, model, "clinics")}
          isSelected={"clinics" === selectedTabKey(model)}
        />
        {contentCategoryTabs(model, dispatch)}
      </NavTabs>
    );
  }
  else {
    return <span></span>;
  }
};

export default NavTabsController;
