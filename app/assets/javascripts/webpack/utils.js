var pick = require("lodash/object/pick");
var keys = require("lodash/object/keys");

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
  }
}
