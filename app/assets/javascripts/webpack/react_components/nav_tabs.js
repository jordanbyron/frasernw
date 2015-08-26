var React = require("react");

module.exports = React.createClass({
  className: function(tabKey) {
    if (tabKey === this.props.selectedTab) {
      return "active";
    } else {
      return "";
    }
  },
  render: function() {
    return (
      <ul className="nav nav-tabs" style={{marginLeft: "0px"}}>
        {
          this.props.tabs.map((tab, index) => {
            return(
              <li onClick={this.props.onTabClick(tab.key)}
                key={index}
                className={this.className(tab.key)}
              >
                <a>{ tab.label }</a>
              </li>
            );
          })
        }
      </ul>
    );
  }
});
