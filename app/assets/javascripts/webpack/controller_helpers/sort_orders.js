import _ from "lodash";
import { headingArrowDirection, selectedTableHeadingKey }
  from "controller_helpers/table_headings";
import { route } from "controller_helpers/routing";

const sortOrders = (model) => {
  if(_.includes([
    "/specialties/:id",
    "/areas_of_practice/:id",
    "/content_categories/:id",
    "/hospitals/:id",
    "/languages/:id"
  ], route)) {

    return reversed(model);
  }

  if(route === "/reports/referents_by_specialty" &&
    selectedTableHeadingKey(model) === "SPECIALTY") {

    return reversed(model);
  }

  if((route === "/news_items" || route == "/news_items/archive") &&
    _.includes(["TYPE", "DIVISION", "TITLE"], selectedTableHeadingKey(model))) {

    return reversed(model);
  }

  if (_.includes(["/issues"], route)) {
    return reversed(model);
  }

  return matching(model);
};

const matching = (model) => {
  return _.times(3, () => {
    if (headingArrowDirection(model) === "UP"){
      return "asc";
    }
    else if (headingArrowDirection(model) === "DOWN") {
      return "desc";
    }
  });
}

const reversed = (model) => {
  return _.times(3, () => {
    if (headingArrowDirection(model) === "UP"){
      return "desc";
    }
    else if (headingArrowDirection(model) === "DOWN") {
      return "asc";
    }
  });
};

export default sortOrders;
