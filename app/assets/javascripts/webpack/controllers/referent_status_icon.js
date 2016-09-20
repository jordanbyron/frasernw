import React from "react";

const ReferentStatusIcon = React.createClass({
  componentDidMount: function() {
    if(this.props.tooltip) {
      $(this.refs.icon).tooltip({
        placement: "right",
        trigger: "hover",
        animation: "true",
        title: tooltipLabel(this.props.model, this.props.record),
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
            referentStatusIcons[this.props.record.referralIconKey]
          }
      />
    );
  }
});

const tooltipLabel = (model, record) => {
  return model.
    app.
    referralTooltips[record.collectionName][record[tooltipLabelKey(record)]];
}


const elemId = (record) => {
  return `${record.collectionName}${record.id}-status-icon`
};

export default ReferentStatusIcon;
