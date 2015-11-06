var React = require("react");
var React = require("react");
var FavoriteIcon = require("./icons/favorite");
var FeedbackIcon = require("./icons/feedback");
var SharedCareIcon = require("./icons/shared_care");


module.exports = React.createClass({
  propTypes: {
    panelKey: React.PropTypes.string,
    records: React.PropTypes.arrayOf(React.PropTypes.shape({
      id: React.PropTypes.number,
      content: React.PropTypes.string
    })),
    categoryLink: React.PropTypes.shape({
      link: React.PropTypes.string,
      text: React.PropTypes.string
    }),
    favorites: React.PropTypes.shape({
      contentItems: React.PropTypes.array
    })
  },
  render: function() {
    return(
      <div>
        {
          this.props.records.map((resource) => {
            return(
              <div className="scm" key={this.props.panelKey + resource.id}>
                <h1>
                  <SharedCareIcon shouldDisplay={resource.isSharedCare} color="red"/>
                  <span>{resource.title}</span>
                  <FavoriteIcon record={resource}
                    favorites={this.props.favorites}
                    dispatch={this.props.dispatch}
                    collection="contentItems"
                    collectionPath="content_items"
                  />
                  <FeedbackIcon record={resource} itemType="ScItem" dispatch={this.props.dispatch}/>
                </h1>
                <div dangerouslySetInnerHTML={{__html: resource.content}}/>
              </div>
            );
          })
        }
        <hr/>
        { categoryLink(this.props.categoryLink) }
      </div>
    );
  }
})


const categoryLink = (categoryLinkProps) => {
  if(categoryLinkProps) {
    return(
      <div>
        <i className='icon-arrow-right icon-blue' style={{marginRight: "5px"}}></i>
        <a href={this.props.categoryLink.link}>{this.props.categoryLink.text}</a>
      </div>
    );
  }
  else {
    return null;
  }
};
