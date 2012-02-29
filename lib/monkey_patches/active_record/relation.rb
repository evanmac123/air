module ActiveRecord
  class Relation
    def most_recent(number=nil)
      result = order("created_at DESC")
      if number
        result = result.limit(number)
      end

      result
    end
  end
end
