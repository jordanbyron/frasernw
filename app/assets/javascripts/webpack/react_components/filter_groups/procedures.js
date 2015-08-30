var React = require("react");
var ToggleBox = require("../toggle_box");
var CheckBox = require("../checkbox");
var transform = require("lodash/object/transform");
var updateFilter =
  require("../../react_mixins/data_table").updateFilter;

module.exports = React.createClass({
  handleCheckboxUpdate: function(event, key) {
    updateFilter(
      this.props.dispatch,
      "procedures",
      { [key] : event.target.checked }
    );
  },
  renderProcedure: function(procedure, level) {
    return(
      <div>
        <CheckBox
          key={procedure.id}
          changeKey={procedure.id}
          label={this.props.labels.procedures[procedure.id]}
          value={this.props.filterValues.procedures[procedure.id]}
          onChange={this.handleCheckboxUpdate}
          style={{marginLeft: ((level * 20).toString() + "px")}}
        />
        {
          this.renderProcedures(
            procedure.children,
            (level + 1)
          )
        }
      </div>
    );
  },
  renderProcedures: function(procedures, level) {
    return(
      <div>
        {
          procedures.map((procedure) => {
            return this.renderProcedure(procedure, level);
          })
        }
      </div>
    );
  },
  render: function() {
    return (
      <div>
        {
          this.renderProcedures(
            this.props.arrangements.procedures,
            0
          )
        }
      </div>
    );
  }
});
