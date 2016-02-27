import _ from "lodash";

export default function(categoryId, model, divisionIds) {
  var pageSpecificFilter = {
    ["/specialties/:id"]: function(contentItem) {
      return _.includes(contentItem.specializationIds, parseInt(model.ui.location.routeParams.id));
    },
    ["/areas_of_practice/:id"]: function(contentItem) {
      return _.includes(contentItem.procedureIds, parseInt(model.ui.location.routeParams.id));
    },
    ["/content_categories/:id"]: function(contentItem){
      return true;
    }
  }

  return _.chain(model.app.contentItems)
    .values()
    .filter((contentItem) => {
      return (pageSpecificFilter[model.ui.location.route](contentItem) &&
        _.any(_.intersection(contentItem.availableToDivisionIds, divisionIds)) &&
        _.includes(model.app.contentCategories[categoryId].subtreeIds, contentItem.categoryId));
    })
    .value();
};
