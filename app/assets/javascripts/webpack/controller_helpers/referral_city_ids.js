import _ from "lodash";
import { matchedRoute, recordShownByPage } from "controller_helpers/routing";

const referralCityIds = (model) => {
  if (matchedRoute(model) === "/specialties/:id"){
    var specializationIds = [ recordShownByPage(model).id ];
  }
  else if (matchedRoute(model) === "/areas_of_practice/:id"){
    var specializationIds = recordShownByPage(model).specializationIds;
  }

  var eachReferralCities = _.partialRight(_.map, (divisionId) => {
    return _.flatten(specializationIds.map((specializationId) => {
      return state.app.divisions[divisionId].referralCities[specializationId];
    }));
  });

  return model.
    app.
    currentUser.
    divisionIds.
    map((divisionId) => {
      return specializationIds.map((specializationId) => {
        return model.app.divisions[divisionId].referralCities[specializationId];
      }).pwPipe(_.flatten);
    }).pwPipe(_.flatten).
    pwPipe(_.uniq)
}

export default referralCityIds;
