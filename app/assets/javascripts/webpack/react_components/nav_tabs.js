var React = require("react");

module.exports = React.createClass({
  render: function() {
    return (
      <ul className="nav nav-tabs" style={{marginLeft: "0px"}}>
        {
          this.props.tabs.map((tab, index) => {
            return(
              <li onClick={this.props.onTabClick(tab.key)}
                key={index}>
                <a>{ tab.label }</a>
              </li>
            );
          })
        }
      </ul>
    );
  }
});
