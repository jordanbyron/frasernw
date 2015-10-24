var React = require("react");

module.exports = React.createClass({
  propTypes: {
    tabs: React.PropTypes.arrayOf(
      React.PropTypes.shape({
        label: React.PropTypes.string,
        key: React.PropTypes.string
      })
    ),
    selectedTab: React.PropTypes.string
  },
  className: function(tabKey) {
    if (tabKey === this.props.selectedTab) {
      return "active";
    } else {
      return "";
    }
  },
  render: function() {
    return (
      <ul className="nav nav-tabs">
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
