const React = require("react");

const ReferentStatusIcon = React.createClass({
  propTypes: {
    record: React.PropTypes.shape({
      statusClassDescription: React.PropTypes.string.isRequired,
      statusClassKey: React.PropTypes.number.isRequired
    }).isRequired
  },
  componentDidMount: function() {
    $(this.refs.icon).tooltip({
      placement: "right",
      trigger: "hover",
      animation: "true",
      title: this.props.record.statusClassDescription,
      container: this.elemId(),
    });
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
