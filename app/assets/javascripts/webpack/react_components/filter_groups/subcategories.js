var React = require("react");
var CheckBox = require("../checkbox");
var mask = require("../../utils").mask;
var mapValues = require("lodash/object/mapValues");

module.exports = React.createClass({
  handleCheckboxUpdate: function(event, key) {
    this.props.dispatch({
      type: "UPDATE_FILTER",
      filterType: "subcategories",
      update: { [key] : event.target.checked }
    });
  },
  render: function() {
    return (
      <div>
        {
          this.props.filters.subcategories.map((subcategory) => {
            return <CheckBox
              key={subcategory.filterId}
              changeKey={subcategory.filterId}
              label={subcategory.label}
              value={subcategory.value}
              onChange={this.handleCheckboxUpdate} />;
          })
        }
      </div>
    );
  }
});
