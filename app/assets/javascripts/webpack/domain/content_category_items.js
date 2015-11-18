import _ from "lodash";

export default function(categoryId, state, divisionIds) {
  var pageSpecificFilter = {
    specialization: function(contentItem) {
      return _.includes(contentItem.specializationIds, state.ui.specializationId);
    },
    procedure: function(contentItem) {
      return _.includes(contentItem.procedureIds, state.ui.procedureId);
    },
    contentCategory: function(contentItem){
      return true;
    }
  }

  return _.chain(state.app.contentItems)
    .values()
    .filter((contentItem) => {
      return (pageSpecificFilter[state.ui.pageType](contentItem) &&
        _.any(_.intersection(contentItem.availableToDivisionIds, divisionIds)) &&
        _.includes(state.app.contentCategories[categoryId].subtreeIds, contentItem.categoryId));
    })
    .value();
};
