import _ from "lodash";
import { memoizePerRender } from "utils";

const hiddenFromUsers = (record, model) => {
  switch(record.collectionName){
  case "specialists":
    return record.hidden;
  case "clinics":
    return record.hidden;
  case "specializations":
    return _.includes(specializationsShownToUser(model), record.id);
  case "procedures":
    return !_.intersection(
      specializationsShownToUser(model),
      record.specializationIds
    );
  default:
    false
  }
}

const specializationsShownToUser = ((model) => {
  return model.
    app.
    currentUser.
    divisionIds.
    map((id) => model.app.divisions[id].showingSpecializationIds).
    pwPipe(_.some)
}).pwPipe(memoizePerRender);

export default hiddenFromUsers;
