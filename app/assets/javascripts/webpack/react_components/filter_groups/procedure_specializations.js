var React = require("react");
var ToggleBox = require("../toggle_box");
var CheckBox = require("../checkbox");
var transform = require("lodash/object/transform");

module.exports = React.createClass({
  handleCheckboxUpdate: function(event, key) {
    this.props.updateFilter(
      "procedureSpecializations",
      { [key] : event.target.checked }
    );
  },
  renderProcedureSpecialization: function(ps, level) {
    return(
      <div>
        <CheckBox
          key={ps.id}
          changeKey={ps.id}
          label={this.props.labels.procedureSpecializations[ps.id]}
          value={this.props.filterValues.procedureSpecializations[ps.id]}
          onChange={this.handleCheckboxUpdate}
          style={{marginLeft: ((level * 20).toString() + "px")}}
        />
        {
          this.renderProcedureSpecializations(
            ps.children,
            (level + 1)
          )
        }
      </div>
    );
  },
  renderProcedureSpecializations: function(procedureSpecializations, level) {
    return(
      <div>
        {
          procedureSpecializations.map((ps) => {
            return this.renderProcedureSpecialization(ps, level);
          })
        }
      </div>
    );
  },
  render: function() {
    return (
      <div>
        {
          this.renderProcedureSpecializations(
            this.props.arrangements.procedureSpecializations,
            0
          )
        }
      </div>
    );
  }
});
