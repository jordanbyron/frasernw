var objectAssign = require("object-assign");
var pick = require("lodash/object/pick");
var keys = require("lodash/object/keys");
var union = require("lodash/array/union");
var reduce = require("lodash/collection/reduce");
var isObject = require("lodash/lang/isObject");
var _ = require("lodash");

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
  },
  from: function(...args) {
    var startingVal = args.pop();
    return _.flowRight(...args)(startingVal);
  },
  pwConcat: function(ary, obj) {
    return ary.concat(obj);
    // return _.reduce(args, function(memo, val) {
    //   return memo.concat(val);
    // }, [])
  },
  toSentence: function(array) {
    //source: https://gist.github.com/mudge/1076046

    var wordsConnector = ", ",
        twoWordsConnector = " and ",
        lastWordConnector = ", and ",
        sentence;

    switch(array.length) {
      case 0:
        sentence = "";
        break;
      case 1:
        sentence = array[0];
        break;
      case 2:
        sentence = array[0] + twoWordsConnector + array[1];
        break;
      default:
        sentence = array.slice(0, -1).join(wordsConnector) + lastWordConnector + array[array.length - 1];
        break;
    }

    return sentence;
  }
}
