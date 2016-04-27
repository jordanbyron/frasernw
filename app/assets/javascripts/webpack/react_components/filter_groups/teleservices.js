var React = require("react");
var CheckBox = require("react_components/checkbox");

const Teleservices = React.createClass({
  handleRecipientUpdate: function(event, key) {
    this.props.dispatch({
      type: "UPDATE_FILTER",
      filterType: "teleserviceRecipients",
      update: { [key] : event.target.checked }
    });
  },
  handleFeeTypeUpdate: function(event, key) {
    this.props.dispatch({
      type: "UPDATE_FILTER",
      filterType: "teleserviceFeeTypes",
      update: { [key] : event.target.checked }
    });
  },
  render: function() {
    return (
      <div>
        <CheckBox
          key="patient"
          changeKey="patient"
          label="Telehealth patient services"
          value={this.props.filters.teleserviceRecipients.patient}
          onChange={this.handleRecipientUpdate}
        />
        <ExpandingContainer expanded={this.props.filters.teleserviceRecipients.patient}>
          <CheckBox
            key={1}
            changeKey={1}
            label="Initial consultation with a patient"
            value={this.props.filters.teleserviceFeeTypes[1]}
            onChange={this.handleFeeTypeUpdate}
            style={{marginLeft: "20px"}}
          />
          <CheckBox
            key={2}
            changeKey={2}
            label="Follow-up with a patient"
            value={this.props.filters.teleserviceFeeTypes[2]}
            onChange={this.handleFeeTypeUpdate}
            style={{marginLeft: "20px"}}
          />
        </ExpandingContainer>
        <CheckBox
          key="provider"
          changeKey="provider"
          label="Telehealth provider services"
          value={this.props.filters.teleserviceRecipients.provider}
          onChange={this.handleRecipientUpdate}
        />
        <ExpandingContainer expanded={this.props.filters.teleserviceRecipients.provider}>
          <CheckBox
            key={3}
            changeKey={3}
            label="Advice to a health care provider"
            value={this.props.filters.teleserviceFeeTypes[3]}
            onChange={this.handleFeeTypeUpdate}
            style={{marginLeft: "20px"}}
          />
          <CheckBox
            key={4}
            changeKey={4}
            label="Case conferencing with a health care provider"
            value={this.props.filters.teleserviceFeeTypes[4]}
            onChange={this.handleFeeTypeUpdate}
            style={{marginLeft: "20px"}}
          />
        </ExpandingContainer>
      </div>
    );
  }
});

const ExpandingContainer = React.createClass({
  componentDidMount: function(){
    if (this.props.expanded){
      $(this.refs.container).show();
    }
  },
  componentDidUpdate: function(prevProps) {
    var selectedInCurrentProps = this.props.expanded;
    var selectedInPrevProps = prevProps.expanded;

    if (selectedInPrevProps == false && selectedInCurrentProps == true && this.props.children.length > 0) {
      $(this.refs.container).slideDown();
    } else if (selectedInPrevProps == true && selectedInCurrentProps == false){
      $(this.refs.container).slideUp();
    }
  },
  render: function() {
    return(
      <div ref="container" style={{display: "none"}}>
        { this.props.children }
      </div>
    );
  }
})


module.exports = Teleservices;
