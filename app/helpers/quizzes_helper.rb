module QuizzesHelper
  def default_input_field_width; 60; end

  # this does not take into account that more rows may actually be needed if space
  # is added due to word wrapping, but should be a pretty good estimate
  def estimate_rows_for_text_area str, cols
    return 3 if str.nil?
    cols = cols.to_f
    str.split("\n").collect { |line| (line.length / cols).ceil }.collect { |v| v == 0 ? 1 : v }.inject(0) { |sum, i| sum + i }
  end
end
