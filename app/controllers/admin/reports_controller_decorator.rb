Admin::ReportsController.class_eval do

  before_filter :kludge 
  
  def kludge
    return if Admin::ReportsController::AVAILABLE_REPORTS.has_key?(:simple)
    Admin::ReportsController::AVAILABLE_REPORTS.merge!({ :simple => {:name => "Simple", :description => "Simple reporting with oprtions"}  })
  end

  def simple
    search = params[:search] || {}
    search[:meta_sort] = "created_at.asc"
    unless search[:order_created_at_greater_than].blank?
      search[:order_created_at_greater_than] = Time.zone.parse(search[:order_created_at_greater_than]).beginning_of_day rescue Time.zone.now.beginning_of_month
    end
    unless search[:order_created_at_less_than].blank?
      search[:order_created_at_less_than] =
          Time.zone.parse(search[:order_created_at_less_than]).end_of_day rescue ""
    end

    search[:order_completed_at_is_not_null] = true

    @search = LineItem.metasearch(search)
    @data = @search.all.collect {|i| [i.created_at.to_i , i.price * i.quantity ] }
#    @data = [@data]
# csv ?      send_data( render_to_string( :csv , :layout => false) , :type => "application/csv" , :filename => "tilaukset.csv") 
  render :template => "admin/reports/simple" 
  end
end


