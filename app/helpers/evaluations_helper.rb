module EvaluationsHelper
  def evaluation_answer_delimiter answer_count, i
    "<div class=\"delimiter #{ answer_count == 1 ? "non_numeric" : "numeric" }\">#{ answer_count == 1 ? answer_delimiter : i.to_s + '.' }</div>".html_safe
  end
end
