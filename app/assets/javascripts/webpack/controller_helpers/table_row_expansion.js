import { selectedTabKey } from "controller_helpers/nav_tab_keys";
import _ from "lodash";

export const areRowsExpanded = (model) => {
  return _.get(
    model,
    ["ui", "tabs", selectedTabKey(model), "areRowsExpanded"],
    false
  )
}
