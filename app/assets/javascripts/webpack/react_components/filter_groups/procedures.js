var React = require("react");
var ToggleBox = require("../toggle_box");
var CheckBox = require("../checkbox");
var transform = require("lodash/object/transform");
var ProcedureCheckbox = require("./procedure_checkbox");
var ExpandBox = require("../expand_box");

module.exports = React.createClass({
  propTypes: {
    filters: React.PropTypes.shape({
      focusedProcedures: React.PropTypes.array.isRequired,
      unfocusedProcedures: React.PropTypes.array.isRequired
    }).isRequired,
    isExpanded: React.PropTypes.bool,
    dispatch: React.PropTypes.func
  },
  handleCheckboxUpdate: function(event, key) {
    this.props.dispatch({
      type: "UPDATE_FILTER",
      filterType: "procedures",
      update: { [key] : event.target.checked }
    });
  },
  handleToggleExpansion: function(event) {
    event.preventDefault();

    this.props.dispatch({
      type: "TOGGLE_FILTER_EXPANSION",
      filterType: "procedures",
      value: !this.props.isExpanded
    })
  },
  renderProcedures: function(procedures) {
    return(
      <div>
        {
          procedures.map((procedure) => {
            return(
              <ProcedureCheckbox
                key={procedure.id}
                filterId={procedure.id}
                label={procedure.label}
                value={procedure.value}
                children={procedure.children}
                level={0}
                handleCheckboxUpdate={this.handleCheckboxUpdate}
              />
            );
          })
        }
      </div>
    );
  },
  unfocusedProcedures: function() {
    if (this.props.filters.unfocusedProcedures.length > 0) {
      return(
        <ExpandBox
          expanded={this.props.isExpanded}
          handleToggle={this.handleToggleExpansion}
        >
          { this.renderProcedures(this.props.filters.unfocusedProcedures) }
        </ExpandBox>
      );
    } else {
      return null;
    }
  },
  render: function() {
    return (
      <div>
        { this.renderProcedures(this.props.filters.focusedProcedures) }
        { this.unfocusedProcedures() }
      </div>
    );
  }
});
