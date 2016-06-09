import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import * as filterValues from "controller_helpers/filter_values";
import { toSentence } from "utils";

const pageTitleLabel = (model) => {
  switch(matchedRoute(model)){
  case "/reports/pageviews_by_user":
    return "Page Views by User";
  case "/content_categories/:id":
    let parentContentCategory =
      model.app.contentCategories[recordShownByPage(model).ancestry];

    if (parentContentCategory){
      return `${parentContentCategory.name}: ${recordShownByPage(model).name}`;
    }
    else {
      return recordShownByPage(model).name;
    }
  case "/hospitals/:id":
    return recordShownByPage(model).name;
  case "/languages/:id":
    return recordShownByPage(model).name;
  case "/reports/referents_by_specialty":
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
        filter((referent) => {
          return _.includes(referent.divisionIds, parseInt(filterValues.divisionScope(model)));
        }).length;
    }

    return `${scope} ${_.capitalize(filterValues.entityType(model))} (${count} total)`;
  case "/latest_updates":
    let divisionNames = model.ui.persistentConfig.divisionIds.map((id) => {
      return model.app.divisions[id].name;
    });

    return `Latest Specialist and Clinic Updates for ${toSentence(divisionNames)}`;
  case "/reports/entity_page_views":
    if (parseInt(filterValues.divisionScope(model)) === 0) {
      var scopeLabel = "by Page Views";
    }
    else {
      var scopeLabel = "by " +
        model.app.divisions[filterValues.divisionScope(model)].name +
        " Users' Page Views"
    }

    return (
      "Top " +
      _.startCase(filterValues.entityType(model)) +
      " " +
      scopeLabel
    );
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
