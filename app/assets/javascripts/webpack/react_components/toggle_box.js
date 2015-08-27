var React = require("react");
var buttonIsh = require("../stylesets").buttonIsh;
var merge = require("lodash/object/merge");

module.exports = React.createClass({
  iconStyle: {
    background: "transparent url(/img/filtering-divider.png) 0% 50% repeat-y",
    paddingLeft: "10px"
  },
  toggleIconClass: function() {
    if (this.props.open) {
      return "icon-minus";
    } else {
      return "icon-plus";
    }
  },
  componentDidMount: function(){
    if (this.props.open){
      $(React.findDOMNode(this.refs.contents)).slideDown();
    }
  },
  // why does this not break when
  // prevProps.open == true && this.props.open== true?
  // shouldn't there be a 'blip' of 'display: none;'?
  componentDidUpdate: function(prevProps) {
    if (prevProps.open == false && this.props.open == true) {
      $(React.findDOMNode(this.refs.contents)).slideDown();
    } else if (prevProps.open == true && this.props.open == false){
      $(React.findDOMNode(this.refs.contents)).slideUp();
    }
  },
  render: function() {
    return (
      <div>
        <div className="filter_group__title open"
          onClick={this.props.handleToggle}
          style={buttonIsh}
          key="title"
        >
          <span>{ this.props.title }</span>
          <i className={this.toggleIconClass() + " filter_group__toggle"}
            style={this.iconStyle}
          ></i>
        </div>
        <div className={"filter_group__filters "}
          key="contents"
          ref="contents"
          style={{display: "none"}}
        >
          <div style={{paddingTop: "12px", paddingBottom: "12px"}}>
            {
              React.Children.map(this.props.children, (child) => child)
            }
          </div>
        </div>
      </div>
    );
  }
});
