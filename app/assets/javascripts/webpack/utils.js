import _ from "lodash";
import { Promise } from 'es6-promise';

export function Deferred() {
  const d = {};
  d.promise = new Promise(function(resolve, reject) {
      d.resolve = resolve;
      d.reject = reject;
  });
  return d;
};

export function setAllOwnValues(obj, value) {
  for (var key in obj) {
    if (obj.hasOwnProperty(key)) {
      obj[key] = value;
    }
  }

  return obj;
}

export function keysAtTruthyVals(obj) {
  return _.keys(_.pick(obj, (val) => val));
}

export function safeMergeValues(...objects) {
  return reduce((_.union(...objects.map((object) => _.keys(object)))), (memo, key) => {
    var valuesAtKey = objects.map((object) => object[key])
      .filter((value) => value !== undefined);

    if (valuesAtKey.length > 1){
      memo[key] = _.assign({}, ...valuesAtKey);
    } else {
      memo[key] = valuesAtKey[0];
    }

    return memo;
  }, {});
}

export function mask(array, mask) {
  return array.filter((elem) => mask.indexOf(elem) > -1 );
}

export function from(...args) {
  var startingVal = args.pop();
  return _.flowRight(...args)(startingVal);
}

export function pwConcat(ary, obj) {
  return ary.concat(obj);
  // return _.reduce(args, function(memo, val) {
  //   return memo.concat(val);
  // }, [])
}

export function toSentence(array) {
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
