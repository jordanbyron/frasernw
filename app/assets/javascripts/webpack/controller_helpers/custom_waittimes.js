import { matchedRoute, recordShownByPage } from "controller_helpers/routing";
import activatedFilterSubkeys from "controller_helpers/activated_filter_subkeys";
import { collectionShownName } from "controller_helpers/collection_shown";
import { memoizePerRender } from "utils";

export const shouldUseCustomWaittime = ((model) => {
  switch(matchedRoute(model)){
  case "/specialties/:id":
    return activatedFilterSubkeys.procedures(model).length === 1 &&
      (model.app.procedures[activatedFilterSubkeys.procedures(model)].
        customWaittime[collectionShownName(model)]);
  case "/areas_of_practice/:id":
    return ((recordShownByPage(model).customWaittime[collectionShownName(model)] &&
      activatedFilterSubkeys.procedures(model).length === 0) ||
      (!recordShownByPage(model).customWaittime[collectionShownName(model)] &&
        activatedFilterSubkeys.procedures(model).length === 1));
  default:
    return false;
  }
}).pwPipe(memoizePerRender)

export const customWaittimeProcedureId = ((model) => {
  switch(matchedRoute(model)){
  case "/specialties/:id":
    return activatedFilterSubkeys.procedures(model)[0];
  case "/areas_of_practice/:id":
    if(recordShownByPage(model).customWaittime[collectionShownName(model)]){
      return recordShownByPage(model).id
    }
    else {
      return activatedFilterSubkeys.procedures(model)[0];
    }
  }
}).pwPipe(memoizePerRender)
