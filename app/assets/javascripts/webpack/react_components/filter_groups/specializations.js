import CheckBox from "react_components/checkbox";
import React from "react";
import { mapValues } from "lodash";

const SpecializationsFilterGroup = React.createClass({
  handleCheckboxUpdate: function(event, key) {
    this.props.dispatch({
      type: "UPDATE_FILTER",
      filterType: "specializations",
      update: { [key] : event.target.checked }
    });
  },
  render: function() {
    return (
      <div>
        {
          this.props.filters.specializations.map((specialization) => {
            return <CheckBox
              key={specialization.filterId}
              changeKey={specialization.filterId}
              label={specialization.label}
              value={specialization.value}
              onChange={this.handleCheckboxUpdate} />;
          })
        }
      </div>
    );
  }
});

export default SpecializationsFilterGroup;
