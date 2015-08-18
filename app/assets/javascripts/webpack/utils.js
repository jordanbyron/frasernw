module.exports = {
  setAllOwnValues: function(obj, value) {
    for (var key in obj) {
      if (obj.hasOwnProperty(key)) {
        obj[key] = value;
      }
    }

    return obj;
  }
}
