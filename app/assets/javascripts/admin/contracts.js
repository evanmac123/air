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
    , optMrr
    , optcArr
    , mrr
    , arr
    , term
    , revenue
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
  }

  function initArrMrrCalc(){

    $('body').on("change", "#opt_arr, #opt_mrr", function(event){
        var node = $(this)
        arr.val("");
        mrr.val("");
        revenue.addClass("hidden");

        if ($(this).is(optMrr)){
          mrr.parent(".row").removeClass("hidden")
        }else{
          arr.parent(".row").removeClass("hidden")
        }
    });
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


  function init(){
   initDatePickers();
   initJQueryObjects();
   initArrMrrCalc();
   initResourceRowClick();
  }

 return {
   init: init
 };

})();

$(function(){
  Airbo.ContractManager.init();
})
