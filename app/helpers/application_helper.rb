module ApplicationHelper
  def show_path_helper target
    "#{target.class.name.underscore}_path".to_sym
  end

  def edit_path_helper target
    "edit_#{target.class.name.underscore}_path".to_sym
  end

  def substitute_html_breaks str
    h(str).gsub("\n", "<br>").html_safe
  end

  def pluralize_based_on_count str, count
    count == 1 ? str : str.pluralize
  end

  def link_delimiter
    "<div class=delimiter>|</div>".html_safe
  end
end
