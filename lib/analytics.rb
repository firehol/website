module AnalyticsHelper

#  def ga_link(id,url,name)
#   "<a id=\"#{id}\" href=\"#{url}\">#{name}</a>" +
#   "<script>" +
#   "$('##{id}').on('click', function() {" +
#   " ga('send', { 'hitType': 'pageview', 'page': '#{url}' });" +
#   " });" +
#   "</script>"
#  end
  def ga_link(id,url,name)
   "<a id=\"#{id}\" href=\"#{url}\">#{name}</a>"
  end

end

include AnalyticsHelper
