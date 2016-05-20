import { collectionShownName } from "controller_helpers/collection_shown";
import recordsMaskingFilters from "controller_helpers/records_masking_filters";

export const scheduleDays = (model) => {
  switch(collectionShownName(model)){
  case "specialists":
    return [6, 7];
  case "clinics":
    return [1, 2, 3, 4, 5, 6, 7];
  }
};

export const careProviders = (model) => {
  return recordsMaskingFilters(model)
    .map(_.property("careProviderIds"))
    .pwPipe(_.flatten)
    .pwPipe(_.uniq);
};
