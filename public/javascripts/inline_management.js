/* DO NOT MODIFY. This file was compiled Tue, 09 Aug 2011 05:08:03 GMT from
 * /home/tbass/github/quizzer/app/coffeescripts/inline_management.coffee
 */

(function() {
  jQuery(function() {
    window.newFormId = 1;
    $('body').delegate('.inline_displayed .value', 'click', function() {
      return $(this).closest('.inline_displayed').triggerInlineAttributeAction();
    });
    $('body').delegate('.inline_editable .cancel', 'click', function() {
      return $(this).closest('.inline_editable').triggerInlineAttributeAction();
    });
    $('body').delegate('.inline_insert_new', 'click', function() {
      return $(this).triggerInlineInsertAction();
    });
    $('body').delegate('.inline_new .remove', 'click', function(event) {
      event.preventDefault();
      return $(this).closest('.inline_managed').remove();
    });
    $('body').delegate('.inline_extend', 'click', function() {
      return $(this).triggerInlineExtendAction();
    });
    $('body').delegate('.inline_save_all', 'click', function() {
      return $('.inline_managed').find('form').submit();
    });
    $('body').delegate('.inline_retractable .inline_retract', 'click', function() {
      return $(this).closest('.inline_retractable').remove();
    });
    $.ajaxSetup({
      error: function() {
        return alert("An error has occured. Please refresh the page and try again.");
      }
    });
    if ($('.question').size() === 0) {
      return $('.inline_insert_new').triggerInlineInsertAction();
    }
  });
  jQuery.fn.triggerInlineAttributeAction = function() {
    return $.ajax({
      url: $(this).attr('action'),
      data: "attr=" + $(this).attr('attr')
    });
  };
  jQuery.fn.triggerInlineObjectAction = function() {
    return $.ajax({
      url: $(this).attr('action')
    });
  };
  jQuery.fn.triggerInlineInsertAction = function() {
    var timesToAdd;
    $(this).attr('starting_new_form_id', window.newFormId);
    timesToAdd = this.attr('add_per_click');
    if (typeof timesToAdd === 'undefined' || timesToAdd === false) {
      timesToAdd = 1;
    } else {
      timesToAdd = parseInt(timesToAdd);
    }
    $.ajax({
      url: $(this).attr('action'),
      data: "starting_new_form_id=" + window.newFormId + "&count=" + timesToAdd
    });
    return window.newFormId = window.newFormId + timesToAdd;
  };
  jQuery.fn.triggerInlineExtendAction = function() {
    var $clone, $input, new_id;
    $clone = $(this).prev().clone();
    $input = $clone.find('input');
    new_id = parseInt($input.attr('id').match(/attributes_(\d+)_/).shift().split(/_/)[1]) + 1;
    $input.attr('id', $input.attr('id').replace(/attributes_\d+_/, 'attributes_' + new_id + '_'));
    $input.attr('name', $input.attr('name').replace(/attributes\]\[\d+\]/, 'attributes][' + new_id + ']'));
    $input.attr('value', '');
    $clone.find('.extended_only').show();
    return $(this).before($clone);
  };
}).call(this);
