var _ = require("lodash");
var utils = require("utils");

module.exports = function(state) {
  var specializationIds = {
    specialization: function(){ return [ state.ui.specializationId ]; },
    procedure: function(){ return state.app.procedures[state.ui.procedureId].specializationIds; }
  }[state.ui.pageType]();

  var eachReferralCities = _.partialRight(_.map, (divisionId) => {
    return _.flatten(specializationIds.map((specializationId) => {
      return state.app.divisions[divisionId].referralCities[specializationId];
    }));
  });

  return utils.source(
    _.uniq,
    _.flatten,
    eachReferralCities,
    state.app.currentUser.divisionIds
  );
}
