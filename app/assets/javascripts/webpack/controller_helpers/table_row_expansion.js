import { selectedTabKey } from "controller_helpers/tab_keys";
import _ from "lodash";

export const areRowsExpanded = (model) => {
  return _.get(
    model,
    ["ui", "tabs", selectedTabKey(model), "areRowsExpanded"],
    false
  )
}
