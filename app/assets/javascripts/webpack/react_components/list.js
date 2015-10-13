var React = require("react");

var List = React.createClass({
  render: function() {
    return(
      <div>
        <div style={{fontWeight: "bold", fontFamily: "Bitter", fontSize: "12px"}}
          key="title"
        >
          { this.props.title }
        </div>
        {
          this.props.items.map((item) => {
            return(<div key={item}>{item}</div>);
          })
        }
      </div>
    );
  }
})

module.exports = List;
