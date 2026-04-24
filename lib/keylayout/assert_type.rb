class Keylayout
  module AssertType
  private

    def assert_type(value, *klasses)
      return if klasses.any?{ |klass| value.is_a?(klass) }

      fail ArgumentError, "expected a #{klasses.join(' or ')}, got #{value.inspect}"
    end
  end
end
