import { matchedRoute, recordShownByRoute } from "controller_helpers/routing";
import activatedFilterSubkeys from "controller_helpers/activated_filter_subkeys";
import { collectionShownName } from "controller_helpers/collection_shown";
import { memoizePerRender } from "utils";

export const shouldUseCustomWaittime = ((model) => {
  switch(matchedRoute(model)){
  case "/specialties/:id":
    return activatedFilterSubkeys.procedures(model).length === 1 &&
      (model.app.procedures[activatedFilterSubkeys.procedures(model)[0]].
        customWaittime[collectionShownName(model)]);
  case "/areas_of_practice/:id":
    return ((recordShownByRoute(model).customWaittime[collectionShownName(model)] &&
      activatedFilterSubkeys.procedures(model).length === 0) ||
      (!recordShownByRoute(model).customWaittime[collectionShownName(model)] &&
        activatedFilterSubkeys.procedures(model).length === 1 &&
          (model.app.procedures[activatedFilterSubkeys.procedures(model)[0]].
          customWaittime[collectionShownName(model)])));
  default:
    return false;
  }
}).pwPipe(memoizePerRender)

export const customWaittimeProcedureId = ((model) => {
  switch(matchedRoute(model)){
  case "/specialties/:id":
    return activatedFilterSubkeys.procedures(model)[0];
  case "/areas_of_practice/:id":
    if(recordShownByRoute(model).customWaittime[collectionShownName(model)]){
      return recordShownByRoute(model).id
    }
    else {
      return activatedFilterSubkeys.procedures(model)[0];
    }
  }
}).pwPipe(memoizePerRender)
