Admin::ReportsController.class_eval do

  before_filter :kludge 
  
  def kludge
    return if Admin::ReportsController::AVAILABLE_REPORTS.has_key?(:simple)
    Admin::ReportsController::AVAILABLE_REPORTS.merge!({ :simple => {:name => "Simple", :description => "Simple reporting with options"}  })
  end

  def simple
    search = params[:search] || {}
    search[:meta_sort] = "created_at.asc"
    if search[:created_at_greater_than].blank?
      search[:created_at_greater_than] = Time.now - 3.months
    else
      search[:created_at_greater_than] = Time.zone.parse(search[:created_at_greater_than]).beginning_of_day rescue Time.zone.now.beginning_of_month
    end
    unless search[:created_at_less_than].blank?
      search[:created_at_less_than] =
          Time.zone.parse(search[:created_at_less_than]).end_of_day rescue search[:created_at_less_than]
    end
    period = params[:period] || "week"
    price_or = (params[:price_or] || "amount").to_sym
    search[:order_completed_at_is_not_null] = true
#:barWidth => 24*60*60*1000
    @search = LineItem.metasearch(search)
    data = @search.all.collect { |i|  [i.created_at.to_i * 1000 , i.send(price_or) ] }
    @flot_options = { :series => {  :lines =>  { :show => true , :fill => true , :steps => true } } ,
                      :xaxis =>  { :mode => "time" }  
                    }
    @flot_data = [{ :label => :all , :data => bucket_array( data , period )}]
    
# csv ?      send_data( render_to_string( :csv , :layout => false) , :type => "application/csv" , :filename => "tilaukset.csv") 
  render :template => "admin/reports/simple" 
  end
  
  
  # the array is assumed to contain [ js-times (to_i*1000) , number ] arrays
  # a new bucketet array version is returned 
  def bucket_array( array , by)
    ret = [ array.first.dup ]
    array.each_with_index do |value , index |
      next if index == 0
      at , val = value
      last = ret.last
      if( Time.at(at/1000).send(by) == Time.at(last[0]/1000).send(by) )
        last[1] = last[1] + val
      else
        ret << value.dup
      end
    end
    ret
  end
  
end


