module FaqHelper

  def faqs
    @items.select { |item| item[:kind] == 'faq' }
  end

  def faq_groups
    faqs.collect { |item| item[:group] }.sort.uniq.collect
  end

  def faqs_in_group(group)
    faqs.select { |item| item[:group] == group }.sort_by { |p| p[:title] }
  end

  def faq_title(f)
    f[:title].sub(/[^-].*-/, "")
  end

  def faq_id(f)
    "faq-" + f[:group].sub(/-.*/, '') + "-" + f[:title].sub(/-.*/, '')
  end
end

include FaqHelper
