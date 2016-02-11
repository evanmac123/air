Airbo = window.Airbo || {}

Airbo.ContractManager= (function(){
  var datePickerSelector = ".datepicker"
    , arrSelector = "#contract_arr"
    , mrrSelector = "#contract_mrr"
    , optArrSelector = "#opt_arr"
    , optMrrSelector = "#opt_mrr"
    , termSelector = "#contract_term"
    , revenueSelector= ".revenue"
    , resourceSelector= ".resource-row"
    , calculatedRevenueSelector = "#calculated_revenue"
    , calcRevLabelSelector = "#calc_rev_label"
    , recurringAmtSelector = ".recurring-amt"
    , calculatedRevenue
    , recurringAmt
    , calcRevLabel
    , optMrr
    , optcArr
    , mrr
    , arr
    , term
    , revenue
    , calcFactor
  ;

  function initDatePickers(){
    $(datePickerSelector).pickadate();
  }


  function initJQueryObjects(){
    arr = $(arrSelector); 
    mrr = $(mrrSelector); 
    optArr = $(optArrSelector); 
    optMrr = $(optMrrSelector); 
    term = $(termSelector); 
    revenue = $(revenueSelector); 
    calculatedRevenue = $(calculatedRevenueSelector); 
    calcRevLabel = $(calcRevLabelSelector); 
    recurringAmt = $(recurringAmtSelector); 
  }

  function initArrMrrCalc(){

    $('body').on("change", "#opt_arr, #opt_mrr", function(event){
      var radioNode = $(this), txtPrefix;
      revenue.addClass("hidden");
      toggleArrMRR(radioNode)
    });


    $('body').on("blur", recurringAmtSelector, function(event){
        calcRevenue($(this));
    });

  }


  function toggleArrMRR(radioNode){
    var calcNode, prefix;
    calcFactor=1/calcFactor;

    if (radioNode.is(optMrr)){
      calcNode = mrr;
      prefix="Annual ";
    }else{
      calcNode = arr;
      prefix="Monthly ";
    }

    calcRevLabel.text(prefix + "Recurring Revenue (*calculated");
    calcRevenue(calcNode)
    calcNode.parent(".row").removeClass("hidden")
  }


  function initResourceRowClick(){
    $("body").on("click", resourceSelector, function(event){
      var resource = $(this);
      url = resource.data("url");
      if(url !== undefined){
       window.location.href = url
      }
    })

  }

  function calcRevenue(node){
    var value = parseInt(node.val())
      , calculated = value*calcFactor
    ;

    if(!isNaN(calculated)){
      calculatedRevenue.val(calculated.toFixed(0));
    }else{
      calculatedRevenue.val("");
    }
  }

  function initCalcFactor(){
   calcFactor = optArr.is(':checked') ? 1/12 : 12
  }


  function init(){
   initDatePickers();
   initJQueryObjects();
   initArrMrrCalc();
   initCalcFactor();
   initResourceRowClick();

  }

 return {
   init: init
 };

})();

$(function(){
  Airbo.ContractManager.init();
})
