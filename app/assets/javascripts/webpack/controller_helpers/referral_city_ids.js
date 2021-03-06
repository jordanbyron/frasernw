import _ from "lodash";
import { route, recordShownByRoute } from "controller_helpers/routing";
import { memoizePerRender } from "utils";

const referralCityIds = ((model) => {
  if(_.includes(IMPLEMENTED_FOR, route)){
    if (route === "/specialties/:id"){
      var specializationIds = [ recordShownByRoute(model).id ];
    }
    else if (route === "/areas_of_practice/:id"){
      var specializationIds = recordShownByRoute(model).specializationIds;
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
