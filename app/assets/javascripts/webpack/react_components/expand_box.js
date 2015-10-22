var React = require("react");
var buttonIsh = require("../stylesets").buttonIsh;

module.exports = React.createClass({
  componentDidMount: function(){
    if (this.props.expanded){
      $(React.findDOMNode(this.refs.contents)).show();
    }
  },
  componentDidUpdate: function(prevProps) {
    if (prevProps.expanded == false && this.props.expanded == true) {
      $(React.findDOMNode(this.refs.contents)).slideDown();
    } else if (prevProps.expanded == true && this.props.expanded == false){
      $(React.findDOMNode(this.refs.contents)).slideUp();
    }
  },
  toggleText: function() {
    if (this.props.expanded) {
      return "Less...";
    } else {
      return "More...";
    }
  },
  render: function() {
    return (
      <div>
        <a onClick={this.props.handleToggle} style={buttonIsh}>{ this.toggleText() }</a>
        <div style={{display: "none", marginTop: "2px"}} ref="contents">
          {
            React.Children.map(this.props.children, (child) => child)
          }
        </div>
      </div>
    );
  }
});
