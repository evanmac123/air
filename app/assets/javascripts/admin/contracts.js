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
    var calcNode, type;
    calcFactor=1/calcFactor;

    if (radioNode.is(optMrr)){
      calcNode = mrr;
      arr.prop("disabled", true);
      type="Annual ";
    }else{
      calcNode = arr;
      mrr.prop("disabled", true);
      type="Monthly ";
    }

    calcNode.prop("disabled", false);
    calcRevLabel.text( "Calculated " + type +"Recurring Revenue");
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


  function initTableSorting(){
    $("table.sortable").tablesorter(); 
  }

  function init(){
    initJQueryObjects();
    initArrMrrCalc();
    initCalcFactor();
    initResourceRowClick();
    initTableSorting();  
    toggleTabs();

  }

  function toggleTabs(){
    $('#tabs .tab').hide();
    $('#tabs div.tab:first').show();
    $('#tabs ul li:first a').addClass('selected');

    $('#tabs ul li a').click(function(){
      $('#tabs ul li a').removeClass('selected');
      $(this).addClass('selected');
      var currentTab = $(this).attr('href');
      $('#tabs .tab').hide();
      $(currentTab).show();
      return false;
    }); 
  }

 return {
   init: init
 };

})();

$(function(){
  Airbo.ContractManager.init();
})
