import { memoizePerRender } from "utils";
import { route, recordShownByRoute } from "controller_helpers/routing";

export const recordShownByBreadcrumb = ((model) => {
  if (_.includes(
    [ "/clinics/:id", "/specialists/:id", "/content_items/:id" ],
    route
  ) && model.ui.dropdownSpecializationId){
    return model.app.specializations[model.ui.dropdownSpecializationId];
  }
  else if (_.includes(["/specialties/:id", "/areas_of_practice/:id"], route)){
    return recordShownByRoute(model);
  }
  else {
    return null;
  }
}).pwPipe(memoizePerRender)

export const matchesBreadcrumb = (record, model) => {
  switch(route){
  case "/specialists/:id":
  case "/clinics/:id":
  case "/content_items/:id":
    return _.includes(
      record.specializationIds,
      recordShownByBreadcrumb(model).id
    )
  default:
    return true;
  }
}
