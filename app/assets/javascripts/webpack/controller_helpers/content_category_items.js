import _ from "lodash";
import { matchedRoute, matchedRouteParams } from "controller_helpers/routing";

export default function(categoryId, model, divisionIds) {
  var pageSpecificFilter = {
    ["/specialties/:id"]: function(contentItem) {
      return _.includes(
        contentItem.specializationIds,
        parseInt(matchedRouteParams(model).id)
      );
    },
    ["/areas_of_practice/:id"]: function(contentItem) {
      return _.includes(
        contentItem.procedureIds,
        parseInt(matchedRouteParams(model).id)
      );
    },
    ["/content_categories/:id"]: function(contentItem){
      return true;
    }
  }

  return model.app.contentItems
    .pwPipe(_.values)
    .filter((contentItem) => {
      return (
        pageSpecificFilter[matchedRoute(model)](contentItem) &&
        _.any(
          _.intersection(contentItem.availableToDivisionIds, divisionIds)
        ) &&
        _.includes(
          model.app.contentCategories[categoryId].subtreeIds,
          contentItem.categoryId
        )
      );
    });
};
