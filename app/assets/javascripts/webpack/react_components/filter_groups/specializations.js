import React from "react";
import RadioButtons from "react_components/radio_buttons";
import { mapValues } from "lodash";

const SpecializationsFilterGroup = React.createClass({
  handleChange: function(event) {
    if (event.target.checked) {
      this.props.dispatch({
        type: "UPDATE_FILTER",
        filterType: "specializations",
        update: event.target.value
      })
    }
  },
  render: function() {
    return (
      <div>
        <RadioButtons
          options={this.props.filters.specializations.options}
          handleChange={this.handleChange}
        />
      </div>
    );
  }
});

export default SpecializationsFilterGroup;
