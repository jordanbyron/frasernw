import { matchedRoute } from "controller_helpers/routing";
import { showingOtherSpecializations } from "controller_helpers/filter_messages"

const showingMultipleSpecializations = (model) => {
  return showingOtherSpecializations(model) ||
    matchedRoute(model) === "/hospitals/:id" ||
    matchedRoute(model) === "/languages/:id" ||
    matchedRoute(model) === "/areas_of_practice/:id"
}

export default showingMultipleSpecializations;
