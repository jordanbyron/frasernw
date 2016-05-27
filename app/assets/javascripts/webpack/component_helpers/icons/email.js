const EmailIcon = ({record}) => {
  if (record.canEmail){
    return(
      <i
        onClick={
          function(){
            window.location.href=`/content_items/${record.id}/email`
          }
        }
        className="icon-envelope-alt icon-blue"
        title="Email this item"
      />
    );
  } else {
    return <noscript/>;
  }
}
