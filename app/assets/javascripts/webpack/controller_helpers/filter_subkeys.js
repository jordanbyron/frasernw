import { collectionShownName } from "controller_helpers/collection_shown";

export const scheduleDays = (model) => {
  switch(collectionShownName(model)){
  case "specialists":
    return [6, 7];
  case "clinics":
    return [1, 2, 3, 4, 5, 6, 7];
  }
}
