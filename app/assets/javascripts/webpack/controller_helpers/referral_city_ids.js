import _ from "lodash";
import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import { memoize } from "utils";

const referralCityIds = memoize(
  matchedRoute,
  recordShownByPage,
  (model) => model.app.currentUser.divisionIds,
  (model) => model.app.divisions,
  (matchedRoute, recordShownByPage, userDivisionIds, divisions) => {
    if (matchedRoute === "/specialties/:id"){
      var specializationIds = [ recordShownByPage.id ];
    }
    else if (matchedRoute === "/areas_of_practice/:id"){
      var specializationIds = recordShownByPage.specializationIds;
    }

    return userDivisionIds.
      map((divisionId) => {
        return specializationIds.map((specializationId) => {
          return divisions[divisionId].referralCities[specializationId];
        }).pwPipe(_.flatten);
      }).pwPipe(_.flatten).
      pwPipe(_.uniq);
  }
)

export default referralCityIds;
