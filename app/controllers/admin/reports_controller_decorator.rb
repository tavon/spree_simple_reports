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
    @period = params[:period] || "week"
    days = 1
    days = 7 if @period == "week"
    days = 30.5 if @period == "month"
    @price_or = (params[:price_or] || "total").to_sym
    search[:order_completed_at_is_not_null] = true
    @search = LineItem.metasearch(search)
    @flot_options = { :series => {  :bars =>  { :show => true , :barWidth => days * 24*60*60*1000 } , :stack => 1 } , 
                      :legend => {  :container => "#legend"} , 
                      :xaxis =>  { :mode => "time" }  
                    }
    group_data
# csv ?      send_data( render_to_string( :csv , :layout => false) , :type => "application/csv" , :filename => "tilaukset.csv") 
  render :template => "admin/reports/simple" 
  end
  
  def group_data
    @group_by = (params[:group_by] ||:all).to_sym
    flot = {}
    if( @group_by == :all )
      flot[:all] = @search.all 
    else
      @search.all.each do |item|
        bucket = item.send( @group_by )
        flot[ bucket ] = [] unless flot[bucket]
        flot[ bucket ] << item        
      end
    end
    @flot_data = flot.collect do |label , data | 
      chart_data = data.collect {|i| [i.created_at.to_i*1000 , i.send(@price_or)] } ;
      { :label => label.label , :data => bucket_array( chart_data , @period ) } 
    end
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

Symbol.class_eval do
  def label
    self
  end
end
String.class_eval do
  def label
    self
  end
end
Taxon.class_eval do
  def label
    self.name
  end
end
Product.class_eval do
  def label
    self.name
  end
end
Variant.class_eval do 
  def label
    self.full_name
  end
end
LineItem.class_eval do
  def by_taxon
    self.variant.product.taxons.first || "none"
  end
  def by_product
    self.variant.product
  end
  def by_variant
    self.variant
  end
end

