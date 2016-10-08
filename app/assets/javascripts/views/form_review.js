(function( formData ) {
  function show_old_value(form_element, old_value_formatted) {
    form_element.closest('div.control-group, div.changed_wrapper').
      addClass('changed');
    help_span = $(document.createElement('span'));
    help_span.addClass('help-inline');
    help_span.text("Was: " + old_value_formatted);
    form_element.parent().append(help_span);
  }

  function generate_button_name(form_element_id_array) {
    return form_element_id_array[0] +
      '[' +
      form_element_id_array.slice(1).join('][') +
      ']';
  }

  function compareFormElement(form_element_id_array, new_entry_value, options) {
    var highlight_changes = options.highlightChanges;
    if ( $.isArray( new_entry_value ) ) {
      //try as array of checkboxes
      checkbox_selector =
        "input:checkbox[name='" +
          generate_button_name(form_element_id_array) +
          "[]']"

      form_element = $(checkbox_selector);

      if (form_element) {
        $.each(form_element, function( index, checkbox ) {
          checkbox = $(checkbox);
          if (
            checkbox.prop('checked') &&
              (new_entry_value.indexOf(checkbox.val()) == -1)
          ) {
            checkbox.prop('checked', false);
            if (highlight_changes) {
              show_old_value(checkbox, "checked");
            }
          } else if (
            !checkbox.prop('checked') &&
              (new_entry_value.indexOf(checkbox.val()) != -1)
          ) {
            checkbox.prop('checked', true);
            if (highlight_changes) { show_old_value(checkbox, "unchecked"); }
          }
        });
      }
      return;
    }

    //try just as id
    form_element = $('#' + form_element_id_array.join('_'));

    if (!form_element || form_element.length != 1) {
      //try as radio button
      radio_selector =
        "input:radio[name='" +
          generate_button_name(form_element_id_array) +
          "']:checked"
      form_element = $(radio_selector);
    }

    if (!form_element || form_element.length != 1) {
      return;
    }

    switch(form_element.prop("tagName")) {
      case('INPUT'):
        switch(form_element.attr('type')) {
          case('radio'):
            old_entry_value = form_element.val();
            if (old_entry_value != new_entry_value) {
              form_element.prop('checked', false);
              $(
                "input:radio[name='" +
                  generate_button_name(form_element_id_array) +
                  "'][value='" +
                  new_entry_value +
                  "']"
              ).prop('checked', true);
              if (highlight_changes) {
                old_value_formatted = form_element.closest('label').text()
                show_old_value(form_element, old_value_formatted);
              }
            }
            break;
          case('checkbox'):
            if (form_element.prop('checked') && (new_entry_value == "0")) {
              form_element.prop('checked', false);
              if (highlight_changes) {
                show_old_value(form_element, "checked");
              }
            } else if (
              !form_element.prop('checked') && (new_entry_value == "1")
            ) {
              form_element.prop('checked', true);
              if (highlight_changes) {
                show_old_value(form_element, "unchecked");
              }
            }
            break;
          case('text'):
          case('tel'):
          case('email'):
          case('url'):
            old_entry_value = form_element.val();
            if (old_entry_value != new_entry_value) {
              form_element.val(new_entry_value);
              if (highlight_changes) {
                old_value_formatted =
                  old_entry_value != "" ? old_entry_value : "blank";
                show_old_value(form_element, old_value_formatted);
              }
            }
            break;
          default:
            break;
        }
        break;
      case('TEXTAREA'):
        old_entry_value = form_element.val();
        if (
          old_entry_value.replace(/(\r\n|\n|\r)/gm,"") !=
            new_entry_value.replace(/(\r\n|\n|\r)/gm,"")
        ) {
          form_element.val(new_entry_value);
          if (highlight_changes)
          {
            old_value_formatted =
              old_entry_value != "" ? old_entry_value : "blank";
            show_old_value(form_element, old_value_formatted);
          }
        }
        break;
      case('SELECT'):
        old_entry_value = form_element.val();
        if (old_entry_value != new_entry_value) {
          form_element.val(new_entry_value);
          if (highlight_changes) {
            old_value_formatted =
              old_entry_value != "" ?
                $(
                  '#' +
                    form_element_id_array.join('_') +
                    ' option[value=\'' +
                    old_entry_value +
                    '\']'
                ).text(): "blank";
            show_old_value(form_element, old_value_formatted);
          }
        }
        break;
      default:
        break;
    }
  }

  function overlayFormData(id_array, review_item, options) {
    $.each(review_item, function(entry_key, new_entry_value) {
      local_id_array = id_array.slice(0);
      //fix up ids that look like part1(part2) into part1_part2
      entry_key = entry_key.replace("(","_").replace(")","");
      local_id_array.push(entry_key);
      if ( $.isPlainObject(new_entry_value) ) {
        overlayFormData(
          local_id_array,
          new_entry_value,
          { highlightChanges: options.highlightChanges }
        );
      } else {
        compareFormElement(
          local_id_array,
          new_entry_value,
          { highlightChanges: options.highlightChanges }
        );
      }
    });
  }

  // only for clinics
  function overlayFocusesFormData(review_item, options) {
    var focuses_mapped = review_item["focuses_mapped"] || {};
    $("input.focus").each( function() {
      var $this = $(this);
      if ($this.prop('checked')) {
        var checkbox_id = $this.attr('id').substring("focuses_mapped_".length);
        if (!focuses_mapped[checkbox_id]) {
          $this.prop('checked', false);
          if (options.highlightChanges) { show_old_value($this, "checked"); }
        }
      }
    });
    overlayFormData(
      ["focuses_mapped"],
      focuses_mapped,
      { highlightChanges: options.highlightChanges }
    );
    overlayFormData(
      ["focuses_investigations"],
      review_item["focuses_investigations"],
      { highlightChanges: options.highlightChanges }
    );
    if (review_item["focuses_waittime"]) {
      overlayFormData(
        ["focuses_waittime"],
        review_item["focuses_waittime"],
        { highlightChanges: options.highlightChanges }
      );
    }
    if (review_item["focuses_lagtime"]) {
      overlayFormData(
        ["focuses_lagtime"],
        review_item["focuses_lagtime"],
        { highlightChanges: options.highlightChanges }
      );
    }
  }

  // only for specialists
  function overlayCapacitiesFormData(review_item, options) {
    var capacities_mapped = review_item["capacities_mapped"] || {};
    $("input.capacity").each( function() {
      var $this = $(this);
      if ($this.prop('checked')) {
        var checkbox_id =
          $this.attr('id').substring("capacities_mapped_".length);
        if (!capacities_mapped[checkbox_id]) {
          $this.prop('checked', false);
          if (options.highlightChanges) { show_old_value($this, "checked"); }
        }
      }
    });
    overlayFormData(
      ["capacities_mapped"],
      capacities_mapped,
      { highlightChanges: options.highlightChanges }
    );
    overlayFormData(
      ["capacities_investigations"],
      review_item["capacities_investigations"],
      { highlightChanges: options.highlightChanges }
    );
    if (review_item["capacities_waittime"]) {
      overlayFormData(
        ["capacities_waittime"],
        review_item["capacities_waittime"],
        { highlightChanges: options.highlightChanges }
      );
    }
    if (review_item["capacities_lagtime"]) {
      overlayFormData(
        ["capacities_lagtime"],
        review_item["capacities_lagtime"],
        { highlightChanges: options.highlightChanges }
      );
    }
  }

  // 'location_is' may have changed; update inputs accordingly
  var maskLocationInputs = function() {
    for (var i = 0; i < formData.maxLocations; ++i) {
      if ($('#location_tab_' + i + ' .changed').length !== 0) {
        $('a[href="#location_tab_' + i + '"]').addClass('changed');
        if (formData.recordKey === "clinic") {
          clinic_address_location_changed(i);
        } else if (formData.recordKey === "specialist") {
          address_location_changed(i);
        }
      }
    }
  }

  var highlightNewNote = function(review_item) {
    $('div[edit_source_id="' + review_item.secret_token_id + '"]').
      addClass('changed');
  }

  var mimicBeforeEdit = function() {
    overlayFormData(
      [formData.recordKey],
      formData.baseReviewItem[formData.recordKey],
      { highlightChanges: false }
    );
    if (formData.recordKey === "clinic") {
      overlayFocusesFormData(
        formData.baseReviewItem,
        { highlightChanges: false }
      );
    } else if (formData.recordKey === "specialist") {
      overlayCapacitiesFormData(
        formData.reviewItem,
        { highlightChanges: false }
      );
    }
  }

  var overlayUserChanges = function() {
    overlayFormData(
      [formData.recordKey],
      formData.reviewItem[formData.recordKey],
      { highlightChanges: true }
    );
    if (formData.recordKey === "clinic") {
      overlayFocusesFormData(
        formData.reviewItem,
        { highlightChanges: true }
      );
    } else if (formData.recordKey === "specialist") {
      overlayCapacitiesFormData(
        formData.reviewItem,
        { highlightChanges: true }
      );
    }
  }

  $(document).ready(function() {
    if (formData.interactionType == 'rereview') {
// roll back to the version the user would have seen before they started editing
      mimicBeforeEdit();
    }
    overlayUserChanges();
    highlightNewNote(formData.reviewItem);
    maskLocationInputs();
// ensure edited '.scheduled' elements are visible
    $(".scheduled").each(scheduled_changed);
  });
}( window.pathways.formData ));
