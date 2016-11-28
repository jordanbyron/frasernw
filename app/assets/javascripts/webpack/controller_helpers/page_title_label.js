import { route, recordShownByRoute } from "controller_helpers/routing";
import * as filterValues from "controller_helpers/filter_values";
import { toSentence } from "utils";
import _ from "lodash";
import entityPageViews from "controller_helpers/page_title_label/entity_page_views";
import divisionIds from "controller_helpers/division_ids";

const pageTitleLabel = (model) => {
  switch(route){
  case "/reports/page_views_by_user":
    return "Page Views by User";
  case "/content_categories/:id":
    let parentContentCategory =
      model.app.contentCategories[recordShownByRoute(model).ancestry];

    if (parentContentCategory){
      return `${parentContentCategory.name}: ${recordShownByRoute(model).name}`;
    }
    else {
      return recordShownByRoute(model).name;
    }
  case "/hospitals/:id":
    return recordShownByRoute(model).name;
  case "/languages/:id":
    return recordShownByRoute(model).name;
  case "/reports/profiles_by_specialty":
    if (parseInt(filterValues.divisionScope(model)) === 0) {
      var scope = "Pathways";
      var count = model.
        app[filterValues.entityType(model)].
        pwPipe(_.values).
        length;
    } else {
      var scope = model.app.divisions[filterValues.divisionScope(model)].name;
      var count = model.
        app[filterValues.entityType(model)].
        pwPipe(_.values).
        filter((profile) => {
          return _.includes(divisionIds(model, profile),
            parseInt(filterValues.divisionScope(model)));
        }).length;
    }

    return `${scope} ${_.capitalize(filterValues.entityType(model))} (${count} total)`;
  case "/latest_updates":
    let divisionNames = model.ui.persistentConfig.divisionIds.map((id) => {
      return model.app.divisions[id].name;
    });

    return `Latest Specialist and Clinic Updates for ${toSentence(divisionNames)}`;
  case "/reports/entity_page_views":
    return entityPageViews(model);
  case "/news_items":
    return "News Items for " +
      model.app.divisions[model.ui.persistentConfig.divisionId].name;
  case "/issues":
    return "Issues";
  case "/change_requests":
    return "Change Requests";
  }
}


export default pageTitleLabel;
