module ReportsHelper


  # assume the array to contains hashes with :data option to bucket  
  # second arg is the function to call, ie :day , :week (on a time object created fro the integer)
  # the hash stays, but the data values are replaced
  def bucket_data( array , by  )
    by = by.to_sym
    array.each do |has|
      has[:data] = bucket_array( has[:data] , by )
    end
  end

end
