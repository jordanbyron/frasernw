var React = require("react");

var List = React.createClass({
  render: function() {
    return(
      <div>
        <div style={{fontWeight: "bold", fontFamily: "Bitter", fontSize: "14px", marginBottom: "5px"}}
          key="title"
        >
          { this.props.title }
        </div>
        <table className="table">
          <tbody>
            {
              this.props.items.map((item) => {
                return(
                  <tr key={item}>
                    <td>{item}</td>
                  </tr>
                );
              })
            }
          </tbody>
        </table>
      </div>
    );
  }
})

module.exports = List;
