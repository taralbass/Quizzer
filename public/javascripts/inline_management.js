jQuery.fn.triggerInlineAttributeAction = function() {
  $.ajax({
    url: $(this).attr('action'),
    data: "attr=" + $(this).attr('attr')
  });
};

jQuery.fn.triggerInlineObjectAction = function() {
  $.ajax({
    url: $(this).attr('action'),
  });
};

var newFormId = 1
jQuery.fn.triggerInlineInsertAction = function() {
  $(this).attr('starting_new_form_id', newFormId);

  var timesToAdd = this.attr('add_per_click');
  if (typeof timesToAdd === 'undefined' || timesToAdd === false) {
    timesToAdd = 1;
  } else {
    timesToAdd = parseInt(timesToAdd);
  }

  $.ajax({
    url: $(this).attr('action'),
    data: "starting_new_form_id=" + newFormId + "&count=" + timesToAdd
  });

  newFormId = newFormId + timesToAdd;
};

jQuery.fn.triggerInlineExtendAction = function ( fn ) {
  var $clone = $(this).prev().clone();
  var $input = $clone.find('input');
  var new_id = parseInt($input.attr('id').match(/attributes_(\d+)_/).shift().split(/_/)[1]) + 1;
  $input.attr('id', $input.attr('id').replace(/attributes_\d+_/, 'attributes_' + new_id + '_'));
  $input.attr('name', $input.attr('name').replace(/attributes\]\[\d+\]/, 'attributes][' + new_id + ']'));
  $input.attr('value', '');
  $clone.find('.extended_only').show();
  $(this).before($clone);
};

$(function(){
  $('body').delegate('.inline_displayed .value', 'click', function() {
    $(this).closest('.inline_displayed').triggerInlineAttributeAction();
  });
  $('body').delegate('.inline_editable .cancel', 'click', function() {
    $(this).closest('.inline_editable').triggerInlineAttributeAction();
  });
  $('body').delegate('.inline_insert_new', 'click', function() {
    $(this).triggerInlineInsertAction();
  });
  $('body').delegate('.inline_new .remove', 'click', function(event) {
    event.preventDefault();
    $(this).closest('.inline_managed').remove();
  });
  $('body').delegate('.inline_extend', 'click', function() {
    $(this).triggerInlineExtendAction();
  });
  $('body').delegate('.inline_save_all', 'click', function() {
    $('.inline_managed').find('form').submit();
  });
  $('body').delegate('.inline_retractable .inline_retract', 'click', function() {
    $(this).closest('.inline_retractable').remove();
  });

  $.ajaxSetup({
    error: function() {
      alert("An error has occured. Please refresh the page and try again.");
    }
  });

  if ( $('.question').size() == 0 ) {
    $('.inline_insert_new').triggerInlineInsertAction();
  }
});

