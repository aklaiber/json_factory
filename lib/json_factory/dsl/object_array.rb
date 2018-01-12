# frozen_string_literal: true

module JSONFactory
  class DSL
    # Helper method to generate an array of objects.
    #
    #   json.object_array([1,2,3]) do |id|
    #     json.member :id, id
    #   end
    #   # generates: [{"id":1},{"id":2},{"id":2}]
    #
    # The above is equivalent to:
    #
    #   json.array do
    #     [1,2,3].each do |id|
    #       json.object do
    #         json.member :id, id
    #       end
    #     end
    #   end
    #   # generates: [{"id":1},{"id":2},{"id":2}]
    def object_array(collection)
      array do
        collection.each do |*values|
          element do
            object do
              yield(*values)
            end
          end
        end
      end
    end
  end
end
