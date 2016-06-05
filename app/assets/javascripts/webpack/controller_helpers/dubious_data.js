import { matchedRoute } from "controller_helpers/routing";
import { toDate } from "controller_helpers/month_options";
import * as filterValues from "controller_helpers/filter_values";

const isDataDubious = (model) => {
  return matchedRoute(model) === "/reports/entity_page_views" &&
    toDate(filterValues.month(model)) < toDate("201511") &&
    _.includes(["physicianResources", "forms", "patientInfo", "redFlags", "communityServices"],
      filterValues.entityType(model))
}

export default isDataDubious;
