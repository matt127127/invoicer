require 'test_helper'

class InvoiceFlowTest < ActionDispatch::IntegrationTest
  setup do
    Capybara.current_driver = Capybara.javascript_driver
    @client = FactoryGirl.create(:client)
    @client.addresses.create(FactoryGirl.attributes_for(:default_address))
  end

  test "autofill works" do
    visit new_invoice_path
    field = 'invoice_name'
    fill_in('invoice_name', with: 'Test')
    page.execute_script %Q{ $('##{field}').trigger("focus") }
    suggestion = page.find('span.tt-suggestions')
    assert_equal "Test", suggestion.text
    suggestion.click
    %w{address address2 city county country tax_number}.each do |n|
        assert_equal n.capitalize, page.find("#invoice_#{n}").value
    end
  end

  test "it should allow to add invoice items" do
    visit new_invoice_path
    %w{address address2 city county country tax_number}.each do |n|
        fill_in "invoice_#{n}", with: @client.addresses.first.send(n)
    end
  end
end
