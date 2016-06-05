import _ from "lodash";
import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import { memoizePerRender } from "utils";

const referralCityIds = ((model) => {
  if(_.includes(IMPLEMENTED_FOR, matchedRoute(model))){
    if (matchedRoute(model) === "/specialties/:id"){
      var specializationIds = [ recordShownByPage(model).id ];
    }
    else if (matchedRoute(model) === "/areas_of_practice/:id"){
      var specializationIds = recordShownByPage(model).specializationIds;
    }

    return model.app.currentUser.divisionIds.
      map((divisionId) => {
        return specializationIds.map((specializationId) => {
          return model.app.divisions[divisionId].referralCities[specializationId];
        }).pwPipe(_.flatten);
      }).pwPipe(_.flatten).
      pwPipe(_.uniq);
  }
}).pwPipe(memoizePerRender)

const IMPLEMENTED_FOR = [
  "/specialties/:id",
  "/areas_of_practice/:id"
]

export default referralCityIds;
