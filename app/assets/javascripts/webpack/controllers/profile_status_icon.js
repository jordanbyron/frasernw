import React from "react";

const ProfileStatusIcon = React.createClass({
  componentDidMount: function() {
    if(this.props.tooltip) {
      $(this.refs.icon).tooltip({
        placement: "right",
        trigger: "hover",
        animation: "true",
        title: this.props.model.app.referralTooltips[this.props.record.referralIconKey],
        container: elemId(this.props.record),
      });
    }
  },
  render: function() {
    return(
      <i
        id={elemId(this.props.record)}
        ref="icon"
        className={
          this.
            props.
            model.
            app.
            referralIcons[this.props.record.referralIconKey]
          }
      />
    );
  }
});



const elemId = (record) => {
  return `${record.collectionName}${record.id}-status-icon`
};

export default ProfileStatusIcon;
