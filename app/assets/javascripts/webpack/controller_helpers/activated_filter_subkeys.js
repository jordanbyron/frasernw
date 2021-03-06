import * as filterSubkeys from "controller_helpers/filter_subkeys";
import * as filterValues from "controller_helpers/filter_values";
import _ from "lodash";
import { memoizePerRender } from "utils";

const activatedFilterSubkeys = _.map(filterSubkeys, (subkeyFn, filterKey) => {
  return [
    filterKey,
    ((model) => {
      return subkeyFn(model).filter((subkey) => {
        return filterValues[filterKey](model, subkey);
      })
    }).pwPipe(memoizePerRender)
  ]
}).pwPipe(_.zipObject)

export default activatedFilterSubkeys;
