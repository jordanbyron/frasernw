import { route } from "controller_helpers/routing";
import { showingOtherSpecializations } from "controller_helpers/filter_messages"

const showingMultipleSpecializations = (model) => {
  return showingOtherSpecializations(model) ||
    route === "/hospitals/:id" ||
    route === "/languages/:id"
}

export default showingMultipleSpecializations;
