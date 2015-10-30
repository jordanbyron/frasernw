var _ = require("lodash");

module.exports = function(state) {
  return _.chain(state.app.currentUser.divisionIds)
    .map((id) => {
      return state.app.divisions[id].referralCities[state.ui.specializationId];
    })
    .flatten()
    .uniq()
    .value()
}
