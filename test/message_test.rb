require_relative 'test_helper'

describe Docket::Message do
  class MyNewMessage
    include Docket::Message

    attribute :foo_id
    attribute :foo_name
  end

  before do
    @attrs = { foo_id: '9ea20cd2-9f26-4b04-9316-e6c6920ef5ba', foo_name: 'foobar123' }
    @message = MyNewMessage.new @attrs
  end

  it 'can be converted to an attribute hash' do
    @message.attributes.to_json.must_equal @attrs.to_json
  end

  it 'ignores mass-assigned attrs that are not part of the defined interface' do
    MyNewMessage.new(@attrs.merge wat: :bbq).attributes.key?(:wat).must_equal false
  end
end
