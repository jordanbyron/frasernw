import { matchedRoute } from "controller_helpers/routing";
import { showingOtherSpecializations } from "controller_helpers/filter_messages"

const showingMultipleSpecializations = (model) => {
  return showingOtherSpecializations(model) ||
    matchedRoute(model) === "/hospitals/:id" ||
    matchedRoute(model) === "/languages/:id"
}

export default showingMultipleSpecializations;
