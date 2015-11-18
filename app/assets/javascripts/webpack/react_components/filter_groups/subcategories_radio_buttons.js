import React from "react";
import RadioButtons from "react_components/radio_buttons";

const SubcategoriesRadioButtons = React.createClass({
  handleChange: function(event) {
    if (event.target.checked) {
      this.props.dispatch({
        type: "UPDATE_FILTER",
        filterType: "subcategories",
        update: event.target.value
      })
    }
  },
  render: function() {
    return (
      <div>
        <RadioButtons
          options={this.props.filters.subcategories.options}
          handleChange={this.handleChange}
        />
      </div>
    );
  }
});

export default SubcategoriesRadioButtons;
