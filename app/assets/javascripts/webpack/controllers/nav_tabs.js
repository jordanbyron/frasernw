import FilterByRoute from "controllers/filter_by_route";
import _ from "lodash";
import contentCategoryItems from "selectors/content_category_items";
import { selectedPanelKey, panelKey } from "selectors/panel_keys"; // TODO
import { NavTabs, NavTab } from "helpers/nav_tabs";
import { tabClicked } from "actions";
import React from "react";

const contentCategoriesShowingTabs = (model) => {
  return _.filter(
    model.app.contentCategories,
    (category) => {
      return ([1, 3, 4, 5].indexOf(category.displayMask) > -1 &&
        category.ancestry == null &&
        _.keys(contentCategoryItems(category.id, model, model.app.currentUser.divisionIds)).length > 0);
    }
  );
}

const contentCategoryTabs = (model, dispatch) => {
  return(
    _.values(contentCategoriesShowingTabs(model)).map((category) => {
      const _key = panelKey("contentCategories", category.id)
      return(
        <NavTab
          label={category.name}
          key={_key}
          onClick={_.partial(tabClicked, _key, dispatch)}
          isSelected={_key === selectedPanelKey(model)}
        />
      );
    })
  );
}

const Handler = ({model, dispatch}) => {
  return(
    <NavTabs>
      <NavTab
        label="Specialists"
        key="specialists"
        onClick={_.partial(tabClicked, "specialists", dispatch)}
        isSelected={"specialists" === selectedPanelKey(model)}
      />
      <NavTab
        label="Clinics"
        key="clinics"
        onClick={_.partial(tabClicked, "clinics", dispatch)}
        isSelected={"clinics" === selectedPanelKey(model)}
      />
      {contentCategoryTabs(model, dispatch)}
    </NavTabs>
  );
};

const SHOWING_IN_ROUTES = [
  "/specialties/:id",
  "/areas_of_practice/:id"
];

const NavTabsController = ({model, dispatch}) => {
  return(
    <FilterByRoute
      model={model}
      dispatch={dispatch}
      showingInRoutes={SHOWING_IN_ROUTES}
      handler={Handler}
    />
  );
}

export default NavTabsController;
