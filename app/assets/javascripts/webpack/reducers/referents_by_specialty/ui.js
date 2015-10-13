var hasBeenInitialized = require("../has_been_initialized");

module.exports = function(state = {}, action) {
  return {
    hasBeenInitialized: hasBeenInitialized(state.hasBeenInitialized, action)
  };
}
