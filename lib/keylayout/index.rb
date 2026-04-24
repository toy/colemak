require_relative 'base'

class Keylayout
  class Index < Base
    def self.by_id = Hash.new{ |h, key| h[key] = new(id: Integer(key)) }

    def id=(id)
      assert_type id, Integer

      @id = id
    end

    def to_s = id.to_s

    def <=>(other)
      sort_obj <=> other.sort_obj
    end

    def inspect = "<I:#{@id}>"

  protected

    def sort_obj = id
  end
end
