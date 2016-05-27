import * as filterSubkeys from "controller_helpers/filter_subkeys";
import * as filterValues from "controller_helpers/filter_values";
import _ from "lodash";

const activatedFilterSubkeys = _.map(filterSubkeys, (subkeyFn, filterKey) => {
  return [
    filterKey,
    (model) => {
      return subkeyFn(model).filter((subkey) => {
        return filterValues[filterKey](model, subkey);
      })
    }
  ]
}).pwPipe(_.zipObject)

export default activatedFilterSubkeys;
