isPositiveNumber = (n) ->
  typeof(n) == 'number' && !(isNaN n) && n > 0

costTable = [
  {"employeeCount":"10","withoutDiscount":[{"monthly":"$0","annual":"$0"},{"monthly":"$0","annual":"$0"},{"monthly":"$0","annual":"$0"}],"withDiscount":[{"monthly":"$0","annual":"$0"},{"monthly":"$0","annual":"$0"},{"monthly":"$0","annual":"$0"}]},
  {"employeeCount":"50","withoutDiscount":[{"monthly":"$67","annual":"$800"},{"monthly":"$133","annual":"$1,600"},{"monthly":"$333","annual":"$4,000"}],"withDiscount":[{"monthly":"$50","annual":"$600"},{"monthly":"$100","annual":"$1,200"},{"monthly":"$250","annual":"$3,000"}]},
  {"employeeCount":"100","withoutDiscount":[{"monthly":"$133","annual":"$1,600"},{"monthly":"$267","annual":"$3,200"},{"monthly":"$667","annual":"$8,000"}],"withDiscount":[{"monthly":"$100","annual":"$1,200"},{"monthly":"$200","annual":"$2,400"},{"monthly":"$500","annual":"$6,000"}]},
  {"employeeCount":"200","withoutDiscount":[{"monthly":"$183","annual":"$2,200"},{"monthly":"$367","annual":"$4,400"},{"monthly":"$917","annual":"$11,000"}],"withDiscount":[{"monthly":"$138","annual":"$1,650"},{"monthly":"$275","annual":"$3,300"},{"monthly":"$688","annual":"$8,250"}]},
  {"employeeCount":"300","withoutDiscount":[{"monthly":"$233","annual":"$2,800"},{"monthly":"$467","annual":"$5,600"},{"monthly":"$1,167","annual":"$14,000"}],"withDiscount":[{"monthly":"$175","annual":"$2,100"},{"monthly":"$350","annual":"$4,200"},{"monthly":"$875","annual":"$10,500"}]},
  {"employeeCount":"400","withoutDiscount":[{"monthly":"$283","annual":"$3,400"},{"monthly":"$567","annual":"$6,800"},{"monthly":"$1,417","annual":"$17,000"}],"withDiscount":[{"monthly":"$213","annual":"$2,550"},{"monthly":"$425","annual":"$5,100"},{"monthly":"$1,063","annual":"$12,750"}]},
  {"employeeCount":"500","withoutDiscount":[{"monthly":"$333","annual":"$4,000"},{"monthly":"$667","annual":"$8,000"},{"monthly":"$1,667","annual":"$20,000"}],"withDiscount":[{"monthly":"$250","annual":"$3,000"},{"monthly":"$500","annual":"$6,000"},{"monthly":"$1,250","annual":"$15,000"}]},
  {"employeeCount":"750","withoutDiscount":[{"monthly":"$500","annual":"$6,000"},{"monthly":"$1,000","annual":"$12,000"},{"monthly":"$2,500","annual":"$30,000"}],"withDiscount":[{"monthly":"$375","annual":"$4,500"},{"monthly":"$750","annual":"$9,000"},{"monthly":"$1,875","annual":"$22,500"}]},
  {"employeeCount":"1000","withoutDiscount":[{"monthly":"$667","annual":"$8,000"},{"monthly":"$1,333","annual":"$16,000"},{"monthly":"$3,333","annual":"$40,000"}],"withDiscount":[{"monthly":"$500","annual":"$6,000"},{"monthly":"$1,000","annual":"$12,000"},{"monthly":"$2,500","annual":"$30,000"}]},
  {"employeeCount":"2000","withoutDiscount":[{"monthly":"$1,333","annual":"$16,000"},{"monthly":"$2,667","annual":"$32,000"},{"monthly":"$6,667","annual":"$80,000"}],"withDiscount":[{"monthly":"$1,000","annual":"$12,000"},{"monthly":"$2,000","annual":"$24,000"},{"monthly":"$5,000","annual":"$60,000"}]},
  {"employeeCount":"3000","withoutDiscount":[{"monthly":"$2,000","annual":"$24,000"},{"monthly":"$4,000","annual":"$48,000"},{"monthly":"$10,000","annual":"$120,000"}],"withDiscount":[{"monthly":"$1,500","annual":"$18,000"},{"monthly":"$3,000","annual":"$36,000"},{"monthly":"$7,500","annual":"$90,000"}]},
  {"employeeCount":"4000","withoutDiscount":[{"monthly":"$2,667","annual":"$32,000"},{"monthly":"$5,333","annual":"$64,000"},{"monthly":"$13,333","annual":"$160,000"}],"withDiscount":[{"monthly":"$2,000","annual":"$24,000"},{"monthly":"$4,000","annual":"$48,000"},{"monthly":"$10,000","annual":"$120,000"}]},
  {"employeeCount":"5000","withoutDiscount":[{"monthly":"$3,333","annual":"$40,000"},{"monthly":"$6,667","annual":"$80,000"},{"monthly":"$16,667","annual":"$200,000"}],"withDiscount":[{"monthly":"$2,500","annual":"$30,000"},{"monthly":"$5,000","annual":"$60,000"},{"monthly":"$12,500","annual":"$150,000"}]},
  {"employeeCount":"10000","withoutDiscount":[{"monthly":"$4,167","annual":"$50,000"},{"monthly":"$8,333","annual":"$100,000"},{"monthly":"$18,333","annual":"$220,000"}],"withDiscount":[{"monthly":"$3,125","annual":"$37,500"},{"monthly":"$6,250","annual":"$75,000"},{"monthly":"$13,750","annual":"$165,000"}]},
  {"employeeCount":"15000","withoutDiscount":[{"monthly":"$5,000","annual":"$60,000"},{"monthly":"$10,000","annual":"$120,000"},{"monthly":"$20,000","annual":"$240,000"}],"withDiscount":[{"monthly":"$3,750","annual":"$45,000"},{"monthly":"$7,500","annual":"$90,000"},{"monthly":"$15,000","annual":"$180,000"}]},
  {"employeeCount":"20000","withoutDiscount":[{"monthly":"$5,833","annual":"$70,000"},{"monthly":"$11,667","annual":"$140,000"},{"monthly":"$21,667","annual":"$260,000"}],"withDiscount":[{"monthly":"$4,375","annual":"$52,500"},{"monthly":"$8,750","annual":"$105,000"},{"monthly":"$16,250","annual":"$195,000"}]},
  {"employeeCount":"25000","withoutDiscount":[{"monthly":"$6,667","annual":"$80,000"},{"monthly":"$13,333","annual":"$160,000"},{"monthly":"$23,333","annual":"$280,000"}],"withDiscount":[{"monthly":"$5,000","annual":"$60,000"},{"monthly":"$10,000","annual":"$120,000"},{"monthly":"$17,500","annual":"$210,000"}]},
  {"employeeCount":"50000","withoutDiscount":[{"monthly":"$8,889","annual":"$106,667"},{"monthly":"$17,778","annual":"$213,333"},{"monthly":"$31,111","annual":"$373,333"}],"withDiscount":[{"monthly":"$6,667","annual":"$80,000"},{"monthly":"$13,333","annual":"$160,000"},{"monthly":"$23,333","annual":"$280,000"}]},
  {"employeeCount":"75000","withoutDiscount":[{"monthly":"$11,111","annual":"$133,333"},{"monthly":"$22,222","annual":"$266,667"},{"monthly":"$38,889","annual":"$466,667"}],"withDiscount":[{"monthly":"$8,333","annual":"$100,000"},{"monthly":"$16,667","annual":"$200,000"},{"monthly":"$29,167","annual":"$350,000"}]},
  {"employeeCount":"100000","withoutDiscount":[{"monthly":"$13,333","annual":"$160,000"},{"monthly":"$26,667","annual":"$320,000"},{"monthly":"$46,667","annual":"$560,000"}],"withDiscount":[{"monthly":"$10,000","annual":"$120,000"},{"monthly":"$20,000","annual":"$240,000"},{"monthly":"$35,000","annual":"$420,000"}]}
]

employeeCount = () ->
  rawValue = $('.num_of_users').val()
  normalizedValue = rawValue.replace(',', '')
  parseInt(normalizedValue)

findCostRow = () ->
  _employeeCount = employeeCount()
  row = _.find(costTable, (row) -> _employeeCount <= row.employeeCount)
  row || _.last(costTable)

discountApplied = () -> $('.annual_plan').hasClass('selected')

currentCosts = () ->
  row = findCostRow()
  if discountApplied()
    row.withDiscount
  else
    row.withoutDiscount

showCosts = () ->
  $('.plan_cost').html( (index) ->
    costs = currentCosts()[index]
    '<li class="month_cost">' + costs.monthly + '<span>/mo.</span></li>' +
    '<li class="year_cost">' + costs.annual + '<span> for a year</span></li>'
  )

showSetPriceButtons = () -> $('.plan_cost').html(checkPriceHTML)

updatePlanCosts = () ->
  if isPositiveNumber(employeeCount())
    showCosts()
  else
    showSetPriceButtons()

checkPriceHTML = $('.check_price_button').parent().html()

bindBillingCycleSelection = (selector) ->
  billingCycleElements = $('.billing_plans li')

  $(selector).bind('click', (event) ->
    event.preventDefault()
    billingCycleElements.toggleClass('selected')
    updatePlanCosts()
  )

bindUpdatePlanCosts = (selector, eventType) ->
  $(selector).bind(eventType, updatePlanCosts)

bindSetPriceButton = () ->
  $('.check_price_button').click((event) ->
    event.preventDefault()
    $('.num_of_users').focus()
    $('body').scrollTop(0)
  )

window.bindUpdatePlanCosts = bindUpdatePlanCosts
window.bindBillingCycleSelection = bindBillingCycleSelection
window.bindSetPriceButton = bindSetPriceButton
