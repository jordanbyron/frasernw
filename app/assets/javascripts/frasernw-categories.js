function init_category(category_id, inline, procedure_filter)
{
  for(var division_id in filtering.current_divisions)
  {
    add_items_from_division(filtering.content_data[division_id], category_id, inline, procedure_filter);
  }

  update_ui(category_id, inline);
}

function update_ui(category_id, inline)
{
  if (!inline)
  {
    update_subcategories(category_id);
  }
  $('#' + category_id + '_table').trigger('update');
  $('#specialist_table').trigger('sorton', [[[0,0]]]);
}

function add_items_from_division(category_data, category_id, inline, procedure_filter)
{
  for(var item_id in category_data[category_id])
  {
    var item = category_data[category_id][item_id];
    if (procedure_filter != -1)
    {
      if (item.attributes.indexOf('p' + procedure_filter + '_') == -1)
      {
        //the item doesn't belong to the procedure we are filtering on, skip it
        continue;
      }
    }
    var title = item.title;
    var full_title = inline ? item.full_title : "";
    var subcategory = inline ? "" : filtering.global_categories[item.subcategory];
    var type_mask = item.type || -1;
    var url = item.url;
    var markdown = inline ? item.markdown : "";
    var body = inline ? item.body : "";
    var can_email = item.can_email;
    var shared_care = item.shared_care;
    var is_new = item.is_new;
    var attributes = item.attributes;
    add_item(category_id, item_id, title, full_title, url, markdown, body, subcategory, type_mask, can_email, shared_care, is_new, attributes, inline);
  }
}

function add_item(category_id, item_id, title, full_title, url, markdown, body, subcategory, type_mask, can_email, shared_care, is_new, attributes, inline)
{
  var entry_id = category_id + "_" + item_id;
  if ($("#" + entry_id).length > 0)
  {
    //row or item already exists
    return;
  }

  var favorite = "<a href=\"javascript:void(0)\" onclick=\"favorite('content_items'," + item_id + ",'" + title + "')\" title=\"Favourite / un-favourite\"><i class=\"icon-text icon-heart\" id=\"user_favorite_content_items_" + item_id + "\"></i></a>"
  var feedback = "<a href=\"javascript:void(0)\" onclick=\"show_feedback('" + title + "'," + item_id + ")\" title=\"Provide feedback on content\"><i class=\"icon-bullhorn\"></i></a>"
  var new_tag = is_new ? "<span class='new'>new</span> " : ""

  if (inline)
  {
    //add it as an inline entry
    var shared_care_icon = shared_care ? "<i class=\"icon-red icon-star\"></i>" : ""
    var entry_html = "<div class=\"scm\">" + new_tag + "<h1>" + shared_care_icon + " " + full_title + " " + favorite + " " + feedback + "</h1>";
    if (markdown)
    {
      entry_html += $('<div/>').html(body).text();
    }
    else
    {
      entry_html += "<a href=\"" + url + "\" target=\"_blank\">" + title + "</a>";
    }
    $('#' + category_id + '_items').append(entry_html);
  }
  else
  {
    //add it to the table
    var shared_care_icon = shared_care ? "<i class=\"icon-blue icon-star\"></i>" : ""
    var email = can_email ? "<a href=\"/content_items/" + item_id + "/email\" title=\"E-mail to patient\"><i class=\"icon-envelope-alt icon-blue\"></i></a>" : ""

    var row_html = $("<tr id='" + entry_id + "'><td class=\"title\">" + new_tag + "" + shared_care_icon + "<a href='" + url + "' target='_blank' onclick=\"window.pathways.trackContentItem(_gaq, " + item_id + ")\">" + title + "</a></td><td class=\"subcategory\">" + subcategory + "</td><td class=\"favorite\">" + favorite + "</td><td class=\"email\">" + email + "</td><td class=\"fb\">" + feedback + "</td></tr>");

    if (typeof $.fn.ajaxify !== 'function')
    {
      $('#' + category_id + '_table tr:last').after(row_html);
    }
    else
    {
      $('#' + category_id + '_table tr:last').after(row_html.ajaxify());
    }
    $('#' + entry_id).data('attributes', attributes);
  }
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
  $('input.ic[name="ic' + category_id + '"]').each( function() {
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
