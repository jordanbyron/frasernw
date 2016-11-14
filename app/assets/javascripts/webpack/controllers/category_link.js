import React from "react";
import CategoryLink from "component_helpers/category_link";
import { collectionShownName } from "controller_helpers/collection_shown";
import { recordShownByRoute, route } from "controller_helpers/routing";
import { recordShownByTab } from "controller_helpers/nav_tab_keys";

const CategoryLinkController = ({model, dispatch}) => {
  if (collectionShownName(model) !== "contentItems"){

    return <noscript/>
  }

  if (route === "/content_categories/:id"){
    let _category = recordShownByRoute(model);

    if(_category.ancestry) {
      return(
        <CategoryLink
          label={`Browse all ${model.app.contentCategories[_category.ancestry].name} content`}
          url={`/content_categories/${_category.ancestry}`}
        />
      );
    }
    else {
      return <noscript/>;
    }
  }
  else {
    let _category = recordShownByTab(model);

    return(
      <div>
        <hr/>
        <CategoryLink
          url={`/content_categories/${_category.id}`}
          label={`Browse ${_category.name} content from all specialties`}
        />
      </div>
    );
  }
}

export default CategoryLinkController
