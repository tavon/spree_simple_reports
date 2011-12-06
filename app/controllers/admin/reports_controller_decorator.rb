Admin::ReportsController.class_eval do

  before_filter :kludge_simple 
  
  def kludge_simple
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
    @days = 1
    @days = 7 if @period == "week"
    @days = 30.5 if @period == "month"
    @price_or = (params[:price_or] || "total").to_sym
    search[:order_completed_at_is_not_null] = true
    @search = LineItem.metasearch(search)
    @flot_options = { :series => {  :bars =>  { :show => true , :barWidth => @days * 24*60*60*1000 } , :stack => 0 } , 
                      :legend => {  :container => "#legend"} , 
                      :xaxis =>  { :mode => "time" }  
                    }
    group_data
# csv ?      send_data( render_to_string( :csv , :layout => false) , :type => "application/csv" , :filename => "tilaukset.csv") 
  render :template => "admin/reports/simple" 
  end
  
  def group_data
    @group_by = (params[:group_by] ||:all).to_sym
    all = @search.all
    flot = {}
    smallest = all.first.created_at
    largest = all.last.created_at
    if( @group_by == :all )
      flot[:all] = all
    else
      @search.all.each do |item|
        bucket = item.send( @group_by )
        flot[ bucket ] = [] unless flot[bucket]
        flot[ bucket ] << item        
      end
    end
    @flot_data = flot.collect do |label , data |
      { :label => label , :data => bucket_array( data , smallest , largest ) } 
    end
  end

  # a new bucketet array version is returned 
  # a value is creted for every tick between from and two (so all arrays have same length)
  # ticks int he returned array are javascsript times ie milliseconds since 1970
  def bucket_array( array  , from , to )
    rb_tick = (@days * 24 * 60 * 60).to_i
    js_tick = rb_tick * 1000
    from = (from.to_i / rb_tick) * js_tick
    to = (to.to_i / rb_tick)* js_tick
    ret = {}
    while from <= to
      ret[from] = 0
      from += js_tick
    end
    array.each do |item|
      value = item.send(@price_or)
      index = (item.created_at.to_i / rb_tick)*js_tick
      throw ret.to_json unless ret[index]
      ret[index] = ret[index] + value
    end
    ret.sort
  end
  
end

LineItem.class_eval do
  def by_taxon
    if self.variant.product.taxons.first 
      self.variant.product.taxons.first.name
    else
      "none"
    end
  end
  def by_product
    self.variant.product.name
  end
  def by_variant
    self.variant.full_name
  end
end

