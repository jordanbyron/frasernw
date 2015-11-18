import _ from "lodash";

export default function(filterValueOverrides) {
  return _.any(_.values(filterValueOverrides), (filterValue) => {
    return (_.isBoolean(filterValue) ||
      _.isString(filterValue) ||
      _.isNumber(filterValue) ||
      (_.isObject(filterValue) && _.any(_.values(filterValue))));
  })
};
