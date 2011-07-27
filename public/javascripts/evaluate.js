var questionIds;
var currentQuestionId;
var questionIndex = 1;

jQuery.fn.displayNextQuestion = function() {
  if (questionIds.length > 0) {
    currentQuestionId = questionIds.shift();
    $.ajax({
      url: $(this).attr('data-action'),
      data: "question_id=" + currentQuestionId,
      error: function() {
        alert("An error has occured. Please refresh the page and start over.");
      },
    });
  } else {
    $('.evaluation_complete form').submit();
  }
};

$(function() {
  questionIds = jQuery.parseJSON($('#evaluation_in_progress').attr('data-question-ids'));

  $('#evaluation_in_progress .posed_question').displayNextQuestion();

  $('body').delegate('#evaluation_in_progress .result_actions input[type="submit"]', 'click', function () {
    var result = $(this).attr('data-result');

    if (typeof result !== 'undefined' && result !== false) {
      $.ajax({
        type: 'PUT',
        url: $(this).closest('.result_actions').attr('data-action'),
        data: { 'evaluation': { 'results_attributes': [ { 'question_id': currentQuestionId, 'result': result } ] } },
      });
    }

    $('#evaluation_in_progress').find('.result').html("").end().find('.posed_question').displayNextQuestion();
  });

});
