var React = require("react");

module.exports = React.createClass({
  render: function() {
    return(
      <div>
        {
          this.props.records.map((resource) => {
            return(
              <div className="scm" key={resource.collectionName + resource.id}>
                <h1>{resource.title}</h1>
                <div dangerouslySetInnerHTML={{__html: resource.content}}/>
              </div>
            );
          })
        }
      </div>
    );
  }
})
