var React = require("react");
var NavTabs = require("./helpers/nav_tabs");
var SpecialistsTable = require("./partials/specialists_table");
var ClinicsTable = require("./partials/clinics_table");

module.exports = React.createClass({
  tabContents: function() {
    switch( this.props.activeTab){
    case "SPECIALISTS":
      return(
        <SpecialistsTable {...this.props}/>
      );
    case "CLINICS":
      return(
        <ClinicsTable {...this.props}/>
      );
    default:
      return(
        <SpecialistsTable {...this.props}/>
      );
    }
  },
  render: function() {
    return (
      <NavTabs tabs={this.props.tabs} onTabClick={this.onTabClick}/>
      { this.tabContents() }
    );
  }
});
