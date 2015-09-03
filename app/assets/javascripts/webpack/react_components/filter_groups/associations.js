var React = require("react");
var ToggleBox = require("../toggle_box");
var Selector = require("../selector");
var updateFilter =
  require("../../react_mixins/data_table").updateFilter;

module.exports = React.createClass({
  clinicAssociationOptions: function() {
    return [{key: 0, label: "Any"}].concat(this.props.arrangements.clinicAssociations.map((clinicId) => {
      return {
        key: clinicId,
        label: this.props.labels.clinics[clinicId]
      }
    }))
  },
  hospitalAssociationOptions: function() {
    return [{key: 0, label: "Any"}].concat(this.props.arrangements.hospitalAssociations.map((hospitalId) => {
      return {
        key: hospitalId,
        label: this.props.labels.hospitals[hospitalId]
      }
    }));
  },
  handleClinicAssociationUpdate: function(event) {
    updateFilter(
      this.props.dispatch,
      "clinicAssociation",
      parseInt(event.target.value)
    );
  },
  handleHospitalAssociationUpdate: function(event) {
    updateFilter(
      this.props.dispatch,
      "hospitalAssociation",
      parseInt(event.target.value)
    );
  },
  render: function() {
    return (
      <div>
        <Selector
          label="Clinic:"
          options={this.clinicAssociationOptions()}
          value={this.props.filterValues.clinicAssociation}
          onChange={this.handleClinicAssociationUpdate}
        />
        <Selector
          label="Hospital:"
          options={this.hospitalAssociationOptions()}
          value={this.props.filterValues.hospitalAssociation}
          onChange={this.handleHospitalAssociationUpdate}
        />
      </div>
    );
  }
});
