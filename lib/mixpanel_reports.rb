require 'airbo_mixpanel_client'
module MixpanelReports

  class ActivitySessionByUserTypeAndBoard

    #HEADER_ROW =["Board", "Client Admin","User","Guest"]

    #def initialize beg_date=nil, end_date=nil, workbook_title=nil

      #@mixpanel = AirboMixpanelClient.new
      #@beg_date = date_format(beg_date || Date.today.beginning_of_week(:sunday).prev_week(:sunday).at_midnight)
      #@end_date = date_format(end_date || @beg_date.end_of_week(:sunday).end_of_day)
      #@workbook = workbook_title || ENV['KPI_SPREADSHEET_NAME'] 
      #@sheet_name = "Mixpanel Data"
      #@report_data = [HEADER_ROW]
    #end

    #def pull
      #result =  request(endpoint, params)
      #raw_data =  extract_report_data(result)
      #parse_and_transform raw_data
    #end

    #private

    #def extract_report_data result
      #result.fetch("data", {}).fetch("values", [])
    #end

    #def parse_and_transform data

      #data.each_with_object(@report_data) do |(board, _types), rep_data| 
        #row = [board]
        #["client admin", "ordinary user", "guest"].each_with_index do |subkey, col_idx|
          #row.push data.fetch(board, {}).fetch(subkey, {}).values.first
        #end
        #rep_data << row
      #end
    #end

    #def endpoint
      #"segmentation/multiseg"
    #end

    #def params 
      #return {
        #event: 'Activity Session - New',
        #from_date: @beg_date 
        #to_date:  @end_date
        #type: 'unique',
        #unit: 'week',
        #inner: 'properties["user_type"]',
        #outer: 'properties["game"]'
      #}
    #end

  end

end
