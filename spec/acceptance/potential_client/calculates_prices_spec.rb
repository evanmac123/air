require 'acceptance/acceptance_helper'

feature 'Calculates prices' do
  def price_table
    unless @_price_table
      price_csv = <<-END_PRICE_CSV
 10 , $-   , $-   , $-   , $-   , $-   , $-   , $-   , $-   , $-   , $-   , $-   , $-   
 50 , $67 , $133 , $333 , $800 ," $1,600 "," $4,000 ", $50 , $100 , $250 , $600 ," $1,200 "," $3,000 "
 100 , $133 , $267 , $667 ," $1,600 "," $3,200 "," $8,000 ", $100 , $200 , $500 ," $1,200 "," $2,400 "," $6,000 "
 200 , $183 , $367 , $917 ," $2,200 "," $4,400 "," $11,000 ", $138 , $275 , $688 ," $1,650 "," $3,300 "," $8,250 "
 300 , $233 , $467 ," $1,167 "," $2,800 "," $5,600 "," $14,000 ", $175 , $350 , $875 ," $2,100 "," $4,200 "," $10,500 "
 400 , $283 , $567 ," $1,417 "," $3,400 "," $6,800 "," $17,000 ", $213 , $425 ," $1,063 "," $2,550 "," $5,100 "," $12,750 "
 500 , $333 , $667 ," $1,667 "," $4,000 "," $8,000 "," $20,000 ", $250 , $500 ," $1,250 "," $3,000 "," $6,000 "," $15,000 "
 750 , $500 ," $1,000 "," $2,500 "," $6,000 "," $12,000 "," $30,000 ", $375 , $750 ," $1,875 "," $4,500 "," $9,000 "," $22,500 "
" 1,000 ", $667 ," $1,333 "," $3,333 "," $8,000 "," $16,000 "," $40,000 ", $500 ," $1,000 "," $2,500 "," $6,000 "," $12,000 "," $30,000 "
" 2,000 "," $1,333 "," $2,667 "," $6,667 "," $16,000 "," $32,000 "," $80,000 "," $1,000 "," $2,000 "," $5,000 "," $12,000 "," $24,000 "," $60,000 "
" 3,000 "," $2,000 "," $4,000 "," $10,000 "," $24,000 "," $48,000 "," $120,000 "," $1,500 "," $3,000 "," $7,500 "," $18,000 "," $36,000 "," $90,000 "
" 4,000 "," $2,667 "," $5,333 "," $13,333 "," $32,000 "," $64,000 "," $160,000 "," $2,000 "," $4,000 "," $10,000 "," $24,000 "," $48,000 "," $120,000 "
" 5,000 "," $3,333 "," $6,667 "," $16,667 "," $40,000 "," $80,000 "," $200,000 "," $2,500 "," $5,000 "," $12,500 "," $30,000 "," $60,000 "," $150,000 "
" 10,000 "," $4,167 "," $8,333 "," $18,333 "," $50,000 "," $100,000 "," $220,000 "," $3,125 "," $6,250 "," $13,750 "," $37,500 "," $75,000 "," $165,000 "
" 15,000 "," $5,000 "," $10,000 "," $20,000 "," $60,000 "," $120,000 "," $240,000 "," $3,750 "," $7,500 "," $15,000 "," $45,000 "," $90,000 "," $180,000 "
" 20,000 "," $5,833 "," $11,667 "," $21,667 "," $70,000 "," $140,000 "," $260,000 "," $4,375 "," $8,750 "," $16,250 "," $52,500 "," $105,000 "," $195,000 "
" 25,000 "," $6,667 "," $13,333 "," $23,333 "," $80,000 "," $160,000 "," $280,000 "," $5,000 "," $10,000 "," $17,500 "," $60,000 "," $120,000 "," $210,000 "
" 50,000 "," $8,889 "," $17,778 "," $31,111 "," $106,667 "," $213,333 "," $373,333 "," $6,667 "," $13,333 "," $23,333 "," $80,000 "," $160,000 "," $280,000 "
" 75,000 "," $11,111 "," $22,222 "," $38,889 "," $133,333 "," $266,667 "," $466,667 "," $8,333 "," $16,667 "," $29,167 "," $100,000 "," $200,000 "," $350,000 "
" 100,000 "," $13,333 "," $26,667 "," $46,667 "," $160,000 "," $320,000 "," $560,000 "," $10,000 "," $20,000 "," $35,000 "," $120,000 "," $240,000 "," $420,000 "
      END_PRICE_CSV
      raw_prices = CSV.parse(price_csv)

      @_price_table = {}
      raw_prices.each do |row|
        stripped = row.map(&:strip)
        key = stripped[0].gsub(/,/, '').to_i

        @_price_table[key] = {
          :without_discount => {
            :monthly => stripped[1,3],
            :annually => stripped[4,3]
          },
          :with_discount => {
            :monthly => stripped[7,3],
            :annually => stripped[10,3]
          }
        }
      end
    end

    @_price_table
  end

  def set_your_price_buttons
    page.all('.check_price_button')
  end

  def fill_in_employee_number(entry)
    fill_in 'num_of_users', with: entry.to_s
  end

  def click_monthly_pricing
    page.find('.monthly_plan').click
  end

  def click_annual_pricing
    page.find('.annual_plan').click
  end

  def expect_prices(prices)
    prices_per_cell = prices[:monthly].zip(prices[:annually])
    expected_texts = prices_per_cell.map do |price_per_cell|
      monthly_price = price_per_cell.first
      annual_price = price_per_cell.last

      "#{monthly_price}/mo. #{annual_price} for a year"
    end

    page.all('.plan_cost').zip(expected_texts) do |cost_cell, expected_text|
      cost_cell.text.should include(expected_text)
    end
  end

  before do
    visit page_path('pricing')
  end

  it "should have three Set Your Price buttons at first", js: true do
    set_your_price_buttons.should have(3).buttons
  end

  it "should show no Set Your Price buttons after an employee number is filled in", js: true do
    fill_in_employee_number(100)
    set_your_price_buttons.should have(0).buttons

    fill_in_employee_number('')
    set_your_price_buttons.should have(3).buttons

    fill_in_employee_number('oh hey')
    set_your_price_buttons.should have(3).buttons

    fill_in_employee_number(100000)
    set_your_price_buttons.should have(0).buttons

    fill_in_employee_number(0)
    set_your_price_buttons.should have(3).buttons

    fill_in_employee_number(-10)
    set_your_price_buttons.should have(3).buttons
  end

  it "should show the correct prices when some info is entered", js: true do
    price_table.each do |employee_count, expected_prices|
      fill_in_employee_number employee_count
      expect_prices expected_prices[:with_discount]

      click_monthly_pricing
      expect_prices expected_prices[:without_discount]

      click_annual_pricing
      expect_prices expected_prices[:with_discount]
    end
  end

  it "should ignore commas in numbers", js: true do
    fill_in_employee_number "1,000"
    expect_prices price_table[1000][:with_discount]
    fill_in_employee_number "2,000"
    expect_prices price_table[2000][:with_discount]
  end

  it "should leave the buttons as-is if an employee count isn't filled in, and the user switches billing cycle", js: true do
    set_your_price_buttons.should have(3).buttons
    click_monthly_pricing
    set_your_price_buttons.should have(3).buttons
    click_annual_pricing
    set_your_price_buttons.should have(3).buttons
    click_monthly_pricing
    set_your_price_buttons.should have(3).buttons
  end
end
