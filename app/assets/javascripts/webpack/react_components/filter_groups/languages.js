var React = require("react");
var CheckBox = require("../checkbox");
var sortBy = require("lodash/collection/sortBy");
var keys = require("lodash/object/keys");
var updateFilter =
  require("../../react_mixins/data_table").updateFilter;

var component = React.createClass({
  handleLanguageUpdate: function(event, key) {
    updateFilter(
      this.props.dispatch,
      "languages",
      { [key] : event.target.checked }
    );
  },
  handleInterpreterUpdate: function(event, key) {
    updateFilter(
      this.props.dispatch,
      "interpreterAvailable",
      event.target.checked
    );
  },
  render: function() {
    return (
      <div>
        <CheckBox
          key="interpreterAvailable"
          changeKey="interpreterAvailable"
          label={this.props.labels.interpreterAvailable}
          value={this.props.filterValues.interpreterAvailable}
          onChange={this.handleInterpreterUpdate}
        />
        {
          this.props.arrangements.languages.map((id) => {
            return (
              <CheckBox
                key={id}
                changeKey={id}
                label={this.props.labels.languages[id]}
                value={this.props.filterValues.languages[id]}
                onChange={this.handleLanguageUpdate}
              />
            );
          })
        }
      </div>
    );
  }
});

module.exports = component;
