import React from "react";

const IssueComment = React.createClass({
  getInitialState: function() {
    return _.assign({editing: false}, this.props);
  },
  edit: function() {
    this.setState({editing: true});
  },
  onContentChange: function(event){
    this.setState({raw_content: event.target.value});
  },
  save: function() {
    var component = this;

    $.ajax({
      url: `/notes/${this.state.id}`,
      type: "PATCH",
      data: { content: this.state.raw_content },
      success: function(data) {
        component.setState({
          raw_content: data.raw_content,
          content: data.content,
          editing: false
        });
      }
    });
  },
  render: function() {
    return(
      <div className="well" style={{width: "400px"}}>
        <div style={{display: "inline-block"}}>
          <b>{ this.state.author_name }</b>
        </div>
        <div className="pull-right">
          <i>{ this.state.created_at }</i>
        </div>
        {
          !this.state.editing ?
            <div style={{clear: "both", marginTop: "10px"}}
              dangerouslySetInnerHTML={{__html: this.state.content}}
            /> : <div></div>
        }
        {
          this.state.editing ?
            <textarea value={this.state.raw_content}
              onChange={this.onContentChange}
            /> :
            <div></div>
        }
        {
          (this.state.creator_id === this.state.current_user_id) &&
            (!this.state.editing) ?
            <div onClick={this.edit}>Edit</div> : <div></div>
        }
        {
          this.state.editing ?
            <div onClick={this.save}>Save</div> : <div></div>
        }
      </div>
    )
  }
});

export default IssueComment
