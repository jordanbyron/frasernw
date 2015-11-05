const React = require("react");

const ReferentStatusIcon = React.createClass({
  propTypes: {
    record: React.PropTypes.shape({
      statusClassKey: React.PropTypes.number.isRequired
    }).isRequired
  },
  componentDidMount: function() {
    $(this.refs.icon).tooltip({
      placement: "right",
      trigger: "hover",
      animation: "true",
      title: this.tooltip(),
      container: this.elemId(),
    });
  },
  tooltip: function() {
    return this.props.tooltips[this.props.record.collectionName][this.props.record[this.tooltipKey()]];
  },
  tooltipKey: function() {
    return {
      specialists: "statusClassKey",
      clinics: "statusMask",
    }[this.props.record.collectionName];
  },
  elemId: function() {
    return `${this.props.record.collectionName}${this.props.record.id}-status-icon`
  },
  render: function() {
    return(
      <i
        id={this.elemId()}
        ref="icon"
        className={this.props.statusIcons[this.props.record.statusClassKey]}
      />
    );
  }
});

module.exports = ReferentStatusIcon;
