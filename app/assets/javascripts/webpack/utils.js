var pick = require("lodash/object/pick");
var keys = require("lodash/object/keys");
var union = require("lodash/array/union");
var reduce = require("lodash/collection/reduce");
var isObject = require("lodash/lang/isObject");
var objectAssign = require("object-assign");

module.exports = {
  setAllOwnValues: function(obj, value) {
    for (var key in obj) {
      if (obj.hasOwnProperty(key)) {
        obj[key] = value;
      }
    }

    return obj;
  },
  keysAtTruthyVals: function(obj) {
    return keys(pick(obj, (val) => val));
  },
  safeMergeValues: function(...objects) {
    return reduce((union(...objects.map((object) => keys(object)))), (memo, key) => {
      var valuesAtKey = objects.map((object) => object[key])
        .filter((value) => value !== undefined);

      if (valuesAtKey.length > 1){
        memo[key] = objectAssign({}, ...valuesAtKey);
      } else {
        memo[key] = valuesAtKey[0];
      }

      return memo;
    }, {});
  },
  mask: function(array, mask) {
    return array.filter((elem) => mask.indexOf(elem) > -1 );
  }
}
