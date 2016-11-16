import { route, recordShownByRoute } from "controller_helpers/routing";
import activatedFilterSubkeys from "controller_helpers/activated_filter_subkeys";
import { collectionShownName } from "controller_helpers/collection_shown";
import { memoizePerRender } from "utils";

export const useProcedureSpecificWaitTimes = ((model) => {
  switch(route){
  case "/specialties/:id":
    return activatedFilterSubkeys.procedures(model).length === 1 &&
      (model.app.procedures[activatedFilterSubkeys.procedures(model)[0]].
        waitTimesSpecified[collectionShownName(model)]);
  case "/areas_of_practice/:id":
    return ((recordShownByRoute(model).waitTimesSpecified[collectionShownName(model)] &&
      activatedFilterSubkeys.procedures(model).length === 0) ||
      (!recordShownByRoute(model).waitTimesSpecified[collectionShownName(model)] &&
        activatedFilterSubkeys.procedures(model).length === 1 &&
          (model.app.procedures[activatedFilterSubkeys.procedures(model)[0]].
          waitTimesSpecified[collectionShownName(model)])));
  default:
    return false;
  }
}).pwPipe(memoizePerRender)

export const specificWaitTimeProcedureId = ((model) => {
  switch(route){
  case "/specialties/:id":
    return activatedFilterSubkeys.procedures(model)[0];
  case "/areas_of_practice/:id":
    if(recordShownByRoute(model).waitTimesSpecified[collectionShownName(model)]){
      return recordShownByRoute(model).id
    }
    else {
      return activatedFilterSubkeys.procedures(model)[0];
    }
  }
}).pwPipe(memoizePerRender)
