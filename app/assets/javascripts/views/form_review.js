(function( formData ){
  function show_old_value(form_element, old_value_formatted)
  {
    form_element.closest('div.control-group, div.changed_wrapper').addClass('changed');
    help_span = $(document.createElement('span'));
    help_span.addClass('help-inline');
    help_span.text("Was: " + old_value_formatted);
    form_element.parent().append(help_span);
  }

  function generate_button_name(form_element_id_array)
  {
    return form_element_id_array[0] + '[' + form_element_id_array.slice(1).join('][') + ']';
  }

  function compareFormElement(form_element_id_array, new_entry_value, options)
  {
    var highlight_changes = options.highlightChanges;
    // console.log(form_element_id_array + " : " + new_entry_value)
    if ( $.isArray( new_entry_value ) )
    {
      //try as array of checkboxes
      checkbox_selector = "input:checkbox[name='" + generate_button_name(form_element_id_array) + "[]']"
      // console.log(checkbox_selector);

      form_element = $(checkbox_selector);

      if (form_element)
      {
        // console.log(new_entry_value);
        // console.log(form_element_id_array);
        $.each(form_element, function( index, checkbox )
        {
          checkbox = $(checkbox);
          if ( checkbox.prop('checked') && (new_entry_value.indexOf(checkbox.val()) == -1) )
          {
            //was checked, but not in updated list
            checkbox.prop('checked', false); //uncheck
            if (highlight_changes) {
              show_old_value(checkbox, "checked");
            }
          }
          else if ( !checkbox.prop('checked') && (new_entry_value.indexOf(checkbox.val()) != -1) )
          {
            //was unchecked, but now in updated list
            checkbox.prop('checked', true); //check
            if (highlight_changes) { show_old_value(checkbox, "unchecked"); }
          }
        });
      }
      else
      {
        //console.log( "No check boxes for array " + new_entry_value );
      }

      return;
    }

    //try just as id
    form_element = $('#' + form_element_id_array.join('_'));

    if (!form_element || form_element.length != 1)
    {
      //try as radio button
      radio_selector = "input:radio[name='" + generate_button_name(form_element_id_array) + "']:checked"
      form_element = $(radio_selector);
    }

    if (!form_element || form_element.length != 1)
    {
      //console.log("Found nothing with id " + form_element_id_array);
      return;
    }

    //console.log("tag: " + form_element.prop("tagName"));

    switch(form_element.prop("tagName"))
    {
      case('INPUT'):
        //console.log(form_element.attr('type'))
        switch(form_element.attr('type'))
        {
          case('radio'):
            old_entry_value = form_element.val();
            if (old_entry_value != new_entry_value)
            {
              // console.log("RADIO: old_entry_value = " + old_entry_value + ", new_entry_value = " + new_entry_value);
              form_element.prop('checked', false);          // uncheck old value
              $("input:radio[name='" + generate_button_name(form_element_id_array) + "'][value='" + new_entry_value + "']").prop('checked', true);              //check new value
              if (highlight_changes)
              {
                old_value_formatted = form_element.closest('label').text()
                show_old_value(form_element, old_value_formatted);
              }
            }
            break;
          case('checkbox'):
            if (form_element.prop('checked') && (new_entry_value == "0"))
            {
              //was checked, uncheck
              form_element.prop('checked', false);
              if (highlight_changes) { show_old_value(form_element, "checked"); }
            }
            else if (!form_element.prop('checked') && (new_entry_value == "1"))
            {
              //was uncheck, check
              form_element.prop('checked', true);
              if (highlight_changes) { show_old_value(form_element, "unchecked"); }
            }
            break;
          case('text'):
          case('tel'):
          case('email'):
          case('url'):
            old_entry_value = form_element.val();
            if (old_entry_value != new_entry_value)
            {
              //console.log("TEXT: old_entry_value = " + old_entry_value + ", new_entry_value = " + new_entry_value);
              form_element.val(new_entry_value);
              if (highlight_changes)
              {
                old_value_formatted = old_entry_value != "" ? old_entry_value : "blank";
                show_old_value(form_element, old_value_formatted);
              }
            }
            break;
          default:
            //console.log("Don't know how to handle type " + form_element.attr('type'));
            break;
        }
        break;
      case('TEXTAREA'):
        old_entry_value = form_element.val();
        if (old_entry_value.replace(/(\r\n|\n|\r)/gm,"") != new_entry_value.replace(/(\r\n|\n|\r)/gm,""))
        {
          form_element.val(new_entry_value);
          if (highlight_changes)
          {
            old_value_formatted = old_entry_value != "" ? old_entry_value : "blank";
            show_old_value(form_element, old_value_formatted);
          }
        }
        break;
      case('SELECT'):
        old_entry_value = form_element.val();
        if (old_entry_value != new_entry_value)
        {
          //console.log("SELECT: old_entry_value = " + old_entry_value + ", new_entry_value = " + new_entry_value);
          form_element.val(new_entry_value);
          if (highlight_changes)
          {
            old_value_formatted = old_entry_value != "" ? $('#' + form_element_id_array.join('_') + ' option[value=\'' + old_entry_value + '\']').text(): "blank";
            show_old_value(form_element, old_value_formatted);
          }
        }
        break;
      default:
        //console.log("Don't know how to handle form tag " + form_element.prop("tagName"));
        break;
    }
  }

  function overlayFormData(id_array, review_item, options)
  {
    $.each(review_item, function(entry_key, new_entry_value) {
      local_id_array = id_array.slice(0); //array copy
      entry_key = entry_key.replace("(","_").replace(")",""); //fix up ids that look like part1(part2) into part1_part2
      local_id_array.push(entry_key);
      //console.log("traverse: " + local_id_array + " : " + new_entry_value);
      if ( $.isPlainObject(new_entry_value) )
      {
        //recursive
        overlayFormData(
          local_id_array,
          new_entry_value,
          { highlightChanges: options.highlightChanges }
        );
      }
      else
      {
        compareFormElement(
          local_id_array,
          new_entry_value,
          { highlightChanges: options.highlightChanges }
        );
      }
    });
  }

  // only for clinics
  function overlayClinicAreasOfPracticeFormData(review_item, options)
  {
    var clinic_areas_of_practice_mapped = review_item["clinic_areas_of_practice_mapped"] || {};

    $("input.clinic_area_of_practice").each( function() {
      var $this = $(this);
      if ($this.prop('checked'))
      {
        var checkbox_id = $this.attr('id').substring("clinic_areas_of_practice_mapped_".length);
        //console.log(checkbox_id);
        if (!clinic_areas_of_practice_mapped[checkbox_id])
        {
          $this.prop('checked', false);
          if (options.highlightChanges) { show_old_value($this, "checked"); }
        }
      }
    });
    overlayFormData(
      ["clinic_areas_of_practice_mapped"],
      clinic_areas_of_practice_mapped,
      { highlightChanges: options.highlightChanges }
    );
    overlayFormData(
      ["clinic_areas_of_practice_investigations"],
      review_item["clinic_areas_of_practice_investigations"],
      { highlightChanges: options.highlightChanges }
    );
    if (review_item["clinic_areas_of_practice_waittime"])
    {
      overlayFormData(
        ["clinic_areas_of_practice_waittime"],
        review_item["clinic_areas_of_practice_waittime"],
        { highlightChanges: options.highlightChanges }
      );
    }
    if (review_item["clinic_areas_of_practice_lagtime"])
    {
      overlayFormData(
        ["clinic_areas_of_practice_lagtime"],
        review_item["clinic_areas_of_practice_lagtime"],
        { highlightChanges: options.highlightChanges }
      );
    }
  }

  // only for specialists
  function overlaySpecialistAreasOfPracticeFormData(review_item, options)
  {
    var specialist_areas_of_practice_mapped = review_item["specialist_areas_of_practice_mapped"] || {};

    $("input.specialist_area_of_practice").each( function() {
      var $this = $(this);
      if ($this.prop('checked'))
      {
        var checkbox_id = $this.attr('id').substring("specialist_areas_of_practice_mapped_".length);
        //console.log(checkbox_id);
        if (!specialist_areas_of_practice_mapped[checkbox_id])
        {
          $this.prop('checked', false);
          if (options.highlightChanges) { show_old_value($this, "checked"); }
        }
      }
    });
    overlayFormData(
      ["specialist_areas_of_practice_mapped"],
      specialist_areas_of_practice_mapped,
      { highlightChanges: options.highlightChanges }
    );
    overlayFormData(
      ["specialist_areas_of_practice_investigations"],
      review_item["specialist_areas_of_practice_investigations"],
      { highlightChanges: options.highlightChanges }
    );

    if (review_item["specialist_areas_of_practice_waittime"])
    {
      overlayFormData(
        ["specialist_areas_of_practice_waittime"],
        review_item["specialist_areas_of_practice_waittime"],
        { highlightChanges: options.highlightChanges }
      );
    }
    if (review_item["specialist_areas_of_practice_lagtime"])
    {
      overlayFormData(
        ["specialist_areas_of_practice_lagtime"],
        review_item["specialist_areas_of_practice_lagtime"],
        { highlightChanges: options.highlightChanges }
      );
    }
  }

  // 'location_is' may have changed; update inputs accordingly
  var maskLocationInputs = function() {
    for (var i = 0; i < formData.maxLocations; ++i)
    {
      if ($('#location_tab_' + i + ' .changed').length !== 0)
      {
        $('a[href="#location_tab_' + i + '"]').addClass('changed');
        if (formData.recordKey === "clinic") {
          clinic_address_location_changed(i);
        } else if (formData.recordKey === "specialist") {
          address_location_changed(i);
        }
      }
    }
  }
  var mimicBeforeEdit = function() {
    overlayFormData(
      [formData.recordKey],
      formData.baseReviewItem[formData.recordKey],
      { highlightChanges: false }
    );
    if (formData.recordKey === "clinic"){
      overlayClinicAreasOfPracticeFormData(
        formData.baseReviewItem,
        { highlightChanges: false }
      );
    } else if (formData.recordKey === "specialist") {
      overlaySpecialistAreasOfPracticeFormData(
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
      overlayClinicAreasOfPracticeFormData(
        formData.reviewItem,
        { highlightChanges: true }
      );
    } else if (formData.recordKey === "specialist") {
      overlaySpecialistAreasOfPracticeFormData(
        formData.reviewItem,
        { highlightChanges: true }
      );
    }
  }

  $(document).ready(function()
  {
    if (formData.interactionType == 'rereview')
    {
      // roll back to the version the user would have seen before they started editing
      mimicBeforeEdit();
    }
    overlayUserChanges();

    maskLocationInputs();

    // I have no idea about this one
    // are we assuming that all '.scheduled' tags have changed??
    $(".scheduled").each(scheduled_changed);
  });
}( window.pathways.formData ));
