var React = require("react");
var CheckBox = require("../checkbox");
var updateFilter = require("../../react_mixins/data_table").updateFilter;

module.exports = React.createClass({
  handleCheckboxUpdate: function(event, key) {
    updateFilter(
      this.props.dispatch,
      "subcategories",
      { [key] : event.target.checked }
    );
  },
  render: function() {
    return (
      <div>
        {
          this.props.arrangements.subcategories.map((id) => {
            return <CheckBox
              key={id}
              changeKey={id}
              label={this.props.labels.scCategories[id]}
              value={this.props.filterValues.subcategories[id]}
              onChange={this.handleCheckboxUpdate} />;
          })
        }
      </div>
    );
  }
});
