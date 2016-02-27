import ForRoutes from "controllers/for_routes";
import _ from "lodash";
import contentCategoryItems from "selectors/content_category_items";
import { selectedPanelKey, panelKey } from "selectors/panel_keys"; // TODO
import { NavTabs, NavTab } from "helpers/nav_tabs";
import React from "react";


const onTabClick = (key, dispatch, event) => {
  dispatch({
    type: "SELECT_PANEL",
    panel: key
  })
};

const contentCategoriesWithTabs = (model) => {
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
    _.values(contentCategoriesWithTabs(model)).map((category) => {
      const _key = panelKey("contentCategories", category.id)
      return(
        <NavTab
          label={category.name}
          key={_key}
          onClick={_.partial(onTabClick, _key, dispatch)}
          isSelected={_key === selectedPanelKey(model)}
        />
      );
    })
  );
}

const Klass = ({model, dispatch}) => {
  return(
    <NavTabs>
      <NavTab
        label="Specialists"
        key="specialists"
        onClick={_.partial(onTabClick, "specialists", dispatch)}
        isSelected={"specialists" === selectedPanelKey(model)}
      />
      <NavTab
        label="Clinics"
        key="clinics"
        onClick={_.partial(onTabClick, "clinics", dispatch)}
        isSelected={"clinics" === selectedPanelKey(model)}
      />
      {contentCategoryTabs(model, dispatch)}
    </NavTabs>
  );
};

const SUPPORTED_ROUTES = [
  "/specialties/:id",
  "/areas_of_practice/:id"
];

const NavTabsController = ({model, dispatch}) => {
  return(
    <ForRoutes
      model={model}
      dispatch={dispatch}
      supportedRoutes={SUPPORTED_ROUTES}
      klass={Klass}
    />
  );
}

export default NavTabsController;
