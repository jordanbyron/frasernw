import React from "react";

const IssueSubscriptionToggle = React.createClass({
  getInitialState: function() {
    return { hovered: false };
  },
  handleMouseEnter: function(){
    this.setState({hovered: true})
  },
  handleMouseLeave: function() {
    this.setState({hovered: false})
  },
  render: function() {
    return(
      <a className={className(this.props.subscribed, this.state.hovered)}
        href={`/issues/${this.props.issueId}/toggle_subscription`}
        onMouseEnter={this.handleMouseEnter}
        onMouseLeave={this.handleMouseLeave}
        id="toggle-subscription-button"
      >
        <i className="icon icon-rss"/>
        <span>{ ` ${labelText(this.props.subscribed, this.state.hovered)}` }</span>
      </a>
    );
  }
});

const labelText = (subscribed, hovered) => {
  if(subscribed && hovered) {
    return "Unsubscribe";
  }
  else if (subscribed) {
    return "Subscribed";
  }
  else {
    return "Subscribe"
  }
}

const className = (subscribed, hovered) => {
  if(subscribed && hovered){
    return "btn btn-danger";
  }
  else {
    return "btn";
  }
}

export default IssueSubscriptionToggle;
