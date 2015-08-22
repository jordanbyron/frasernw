var React = require("react");
var ToggleBox = require("./toggle_box");
var CheckBox = require("./checkbox");
var transform = require("lodash/object/transform");

module.exports = React.createClass({
  generateFilters: function(filters) {
    return transform(filters, (memo, value, key) => {
      return memo.push({
        key: key,
        value: value.value,
        label: value.label,
        children: this.generateFilters(value.children)
      });
    }, []);
  },
  handleCheckboxUpdate: function(event, key) {
    this.props.updateFilter(
      "procedureSpecializations",
      { [key] : event.target.checked }
    );
  },
  handleToggleVisibility: function(event) {
    this.props.toggleVisibility("procedureSpecializations");
  },
  renderProcedureSpecialization: function(procedureSpecialization, level) {
    return(
      <div>
        <CheckBox
          key={procedureSpecialization.key}
          filterKey={procedureSpecialization.key}
          label={procedureSpecialization.label}
          value={this.props.filters[procedureSpecialization.key]}
          onChange={this.handleCheckboxUpdate}
          style={{marginLeft: ((level * 20).toString() + "px")}}
        />
        {
          procedureSpecialization.children.map((procedureSpecialization) => {
            return this.renderProcedureSpecialization(
              procedureSpecialization,
              (level + 1)
            )
          })
        }
      </div>
    );
  },
  render: function() {
    return (
      <ToggleBox title={"Accepts Referrals For"}
        open={this.props.visible}
        handleToggle={this.handleToggleVisibility}>
        {
          this.props.labels.map((procedureSpecialization) => {
            return this.renderProcedureSpecialization(
              procedureSpecialization,
              0
            )
          })
        }
      </ToggleBox>
    );
  }
});