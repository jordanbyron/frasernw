var React = require("react");

module.exports = React.createClass({
  render: function() {
    return (
      <ul className="nav nav-tabs">
        {
          this.props.tabs.map((tab, index) => {
            return(
              <li onClick={this.props.onTabClick(tab.key)}
                key={index}>
                { tab.label }
              </li>
            );
          })
        }
      </ul>
    );
  }
});
