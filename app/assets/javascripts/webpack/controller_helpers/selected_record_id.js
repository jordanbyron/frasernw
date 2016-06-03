import _ from "lodash"

import { selectedTabKey } from "controller_helpers/tab_keys";

export const selectedRecordId = (model) => {
  return _.get(
    model,
    ["ui", "tabs", selectedTabKey(model), "selectedRecordId"],
    null
  );
};

export default selectedRecordId
