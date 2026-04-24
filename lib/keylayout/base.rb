require_relative 'assert_type'

class Keylayout
  class Base
    include AssertType

    def self.by_id = Hash.new{ |h, key| h[key] = new(id: key) }

    attr_reader :id

    def initialize(id: nil)
      self.id = id if id
    end

    alias_method :to_s, :id

    def id=(id)
      assert_type id, String

      @id = id
    end

    def <=>(other)
      sort_obj <=> other.sort_obj
    end

  protected

    def sort_obj = [id[/\d+/].to_i, id]
  end
end
