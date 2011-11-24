Array.class_eval do
  # assumes an array of arrays with 2 elements, ie graphs
  def to_js
#    graphs = self.collect do |graph|
      elems = self.collect {  |a,b| "[ #{a*1000} , #{b} ]" }
      "[ #{elems.join(' , ')}]"
#    end
#    "[ #{graphs.join(' , ')}]"
  end
  
  def bucket(  days )
    bucket_size = days * 24*60*60
    index = 1
    while index < self.length
      #if the indexes are within the bucket (week/month)
      if self[index][0] - self[index-1][0] < bucket_size
        #add the values up
        self[index-1][1] = self[index-1][1] + self[index][1]
        self.delete_at(index) #so without increasing the index we actually process then next
      else #move on to the next bucket
        index += 2
      end
    end
  end
end
