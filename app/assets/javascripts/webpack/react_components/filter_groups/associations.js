var React = require("react");
var ToggleBox = require("../toggle_box");
var Selector = require("../selector");
var mask = require("../../utils").mask

module.exports = React.createClass({
  propTypes: {
    filters: React.PropTypes.shape({
      clinicAssociations: React.PropTypes.shape({
        value: React.PropTypes.number,
        options: React.PropTypes.arrayOf(React.PropTypes.shape({
          key: React.PropTypes.number,
          label: React.PropTypes.string
        }))
      }),
      hospitalAssociations: React.PropTypes.shape({
        value: React.PropTypes.number,
        options: React.PropTypes.arrayOf(React.PropTypes.shape({
          key: React.PropTypes.number,
          label: React.PropTypes.string
        }))
      })
    })
  },
  handleClinicAssociationUpdate: function(event) {
    this.props.dispatch({
      type: "UPDATE_FILTER",
      filterType: "clinicAssociations",
      update: parseInt(event.target.value)
    });
  },
  handleHospitalAssociationUpdate: function(event) {
    this.props.dispatch({
      type: "UPDATE_FILTER",
      filterType: "hospitalAssociations",
      update: parseInt(event.target.value)
    });
  },
  render: function() {
    return (
      <div>
        <Selector
          label="Clinic:"
          options={this.props.filters.clinicAssociations.options}
          value={this.props.filters.clinicAssociations.value}
          onChange={this.handleClinicAssociationUpdate}
          style={{width: "200px"}}
        />
        <Selector
          label="Hospital:"
          options={this.props.filters.hospitalAssociations.options}
          value={this.props.filters.hospitalAssociations.value}
          onChange={this.handleHospitalAssociationUpdate}
          style={{width: "200px"}}
        />
      </div>
    );
  }
});
