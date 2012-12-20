function init_category(category_id)
{
  for(var division_id in filtering.current_divisions)
  {
    add_items_from_division(filtering.content_data[division_id], category_id);
  }
  
  update_ui(category_id);
}

function update_ui(category_id)
{
  update_subcategories(category_id);
  $('#' + category_id + '_table').trigger('update');
  $('#specialist_table').trigger('sorton', [[[0,0]]]);
}

function add_items_from_division(category_data, category_id)
{
  for(var item_id in category_data[category_id])
  {
    var item = category_data[category_id][item_id];
    var title = item.title;
    var subcategory = filtering.global_categories[item.subcategory];
    var can_email = item.can_email;
    var shared_care = item.shared_care;
    var attributes = item.attributes;
    add_item(category_id, item_id, title, subcategory, can_email, shared_care, attributes);
  }
}

function add_item(category_id, item_id, title, subcategory, can_email, shared_care, attributes)
{
  var row_id = category_id + "_" + item_id;
  if ($("#" + row_id).length > 0)
  {
    //row already exists
    return;
  }
  
  var shared_care_icon = shared_care ? "<i class=\"icon-blue icon-star\"></i>" : ""
  var favorite = "<a href=\"javascript:void(0)\" onclick=\"favorite('content_items'," + item_id + ",'" + title + "')\" title=\"Favourite / un-favourite\"><i class=\"icon-text icon-heart\" id=\"user_favorite_content_items_" + item_id + "\"></i></a>"
  var email = can_email ? "<a href=\"/content_items/" + item_id + "/email\" class=\"ajax\" title=\"E-mail to patient\"><i class=\"icon-envelope-alt icon-blue\"></i></a>" : ""
  var feedback = "<a href=\"javascript:void(0)\" onclick=\"show_feedback('" + title + "'," + item_id + ")\" title=\"Provide feedback on content\"><i class=\"icon-bullhorn\"></i></a>"
  var row_html = $("<tr id='" + row_id + "'><td class=\"title\">" + shared_care_icon + "<a href=\"/content_items/" + item_id + "\" class=\"ajax\">" + title + "</a></td><td class=\"subcategory\">" + subcategory + "</td><td class=\"favorite\">" + favorite + "</td><td class=\"email\">" + email + "</td><td class=\"fb\">" + feedback + "</td></tr>");
  
  if (typeof $.fn.ajaxify !== 'function')
  {
    $('#' + category_id + '_table tr:last').after(row_html);
  }
  else
  {
    $('#' + category_id + '_table tr:last').after(row_html.ajaxify());
  }
  $('#' + row_id).data('attributes', attributes);
}

function update_subcategories(category_id)
{
  var current_subcategories = [];
  
  for(var division_id in filtering.current_divisions)
  {
    current_subcategories = current_subcategories.concat(filtering.current_subcategories[division_id][category_id]);
  }
  
  current_subcategories = current_subcategories.unique();
  
  //hide subcategories that no item has
  $("input.ic[name='ic" + category_id + "']").each( function() {
    $this = $(this)
    if (current_subcategories.indexOf($this.attr('id')) == -1)
    {
      $this.parent().hide();
    }
    else
    {
      $this.parent().show();
    }
  });
}