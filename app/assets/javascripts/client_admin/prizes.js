function addNewPrizeField() {
  initialPrize = $('.prize_section').eq(0);
  //clone from first prize
  var newPrize = initialPrize.clone()
                .find('.character-counter').remove().end()
                .find('.prize_field').val('').end();
  newPrizeField = newPrize.find('.prize_field');
  newPrize.appendTo('#prizes');
  addCharacterCounterFor(newPrizeField);
}

function addNewPreviewPrizeField(){
  initialPrize = $('.prize_row').eq(0);
  var newPrize =  initialPrize.clone().find(".prize_description p").text("").end();
  newPrize.appendTo('.prizes_container');
  updatePrivewPrizeField( $('.prize_row').length - 1 );
}

function saveDraft(){
  $("form[class$='_raffle']").attr("action", "/client_admin/prizes/save_draft")
                             .attr("data-remote", "true")
                             .submit();
  window.draft_saved = true;
}

function startLive(){
  window.draft_saved = true; //to not fire popup
  $("form[class$='_raffle']").attr("action", "/client_admin/prizes/start")
                             .removeAttr("data-remote")
                             .removeData("remote")
                             .submit();
}

function unsavedDraft(){
  //activate save draft button
  if(window.draft_saved){
    $("#save_draft").removeAttr('disabled').text("Save draft");
    window.draft_saved = false;
  }
}

function todayDate(){
  return (new Date()).setHours(0,0,0,0); //today afternoon
}

function validDateFormat(date){
  return /[0-9]+\/[0-9]+\/[0-9]{4,}/.test(date);
}

function endDate(){
  date_input = $("#raffle_ends_at").val();
  if(validDateFormat(date_input)){
    date = (new Date(date_input + " 23:59"));
  }else{
    date = false;
  }
  return date;
}

function startDate(){
  date_input = $("#raffle_starts_at").val();
  if(validDateFormat(date_input)){
    date = (new Date(date_input + " 00:00"));
    if( date.getTime() == todayDate() ){
      date = new Date();
    }
  }else{
    date = false;
  }
  return date;
}

function disableEndDate(){
  return $("#raffle_ends_at").attr("disabled", "disabled").val("");
}

function enableEndDate(){
  return $("#raffle_ends_at").removeAttr("disabled");
}

function validateStartDate(){
  start_date = startDate();
  end_date = endDate();
  today = todayDate();

  if(!start_date){ // not date
    disableEndDate();
  }else if(start_date < today){
    disableEndDate();
    $("#raffle_starts_at").val(""); //delete old date
  }else if(end_date <= start_date){
    enableEndDate();
    $("#raffle_ends_at").val("");
  }else{
    enableEndDate();
  }

  if(startDate()){
    $('#raffle_ends_at').datepicker( 'option', 'minDate',
      new Date( startDate().getTime() + dayDuration() ) );
  }
  updatePickWinnersEndDate();
  updatePreviewEndDate();
  updatePreviewDuration();
}

function validateEndDate(){
  end_date = endDate();
  start_date = startDate();

  if(end_date && start_date && end_date <= start_date){
    $("#raffle_ends_at").val("");
  }

  updatePickWinnersEndDate();
  updatePreviewEndDate();
  updatePreviewDuration();
}

function weekDay(date){
  weekday = new Array(7);
  weekday[0]="Sunday";
  weekday[1]="Monday";
  weekday[2]="Tuesday";
  weekday[3]="Wednesday";
  weekday[4]="Thursday";
  weekday[5]="Friday";
  weekday[6]="Saturday";

  return weekday[date.getDay()];
}

function monthName(date){
  months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'June',
    'July',
    'Aug',
    'Sept',
    'Oct',
    'Nov',
    'Dec'
  ];

  return months[date.getMonth()];
}

function updatePickWinnersEndDate(){
  end_date = endDate();
  text =  "You can pick winners starting ";
  if(end_date > 0){
    end_date = new Date(endDate().getTime() + minuteDuration());
    text += weekDay(end_date) +
            ", " + monthName(end_date) +
            " " + end_date.getDate() + " at 12:00 AM ET";
  }else{
    text = "[Day of week, Month, DD at 12:00 AM] ET";
  }
  $(".pick_winners_from").text(text);
}

function updatePreviewEndDate(){
  end_date = endDate();
  if(end_date > 0){
    text =  "Ends " + weekDay(end_date) +
            ", " + monthName(end_date) +
            " " + end_date.getDate();
  }else{
    text = "Ends [Day of week, MM DD]";
  }
  $(".end_date").text(text);
}

function prizePeriodDuration(){
  if( endDate() && startDate()){
    duration = (endDate() - startDate()) + minuteDuration();
    if(duration <= dayDuration()){
      duration = false;
    }
  }else{
    duration = false;
  }
  return duration;
}

function weekDuration(){
  return 60 * 60 * 24 * 7 * 1000;
}

function dayDuration(){
  return 60 * 60 * 24 * 1000;
}

function hourDuration(){
  return 60 * 60 * 1000;
}

function minuteDuration(){
  return 60 * 1000;
}

function pluralize(word, number){
  return word + (number == 1 ? "" : "s");
}

function updatePreviewDuration(){
  duration = prizePeriodDuration();
  if(!duration){
    first_date_num = 0;
    first_date_text = "weeks";
    second_date_num = 0;
    second_date_text = "days"
  }else if(duration > weekDuration()){
    first_date_num = Math.floor(duration / weekDuration());
    first_date_text = pluralize("week", first_date_num);
    second_date_num = Math.floor(duration / dayDuration()) -
                      first_date_num * weekDuration() / dayDuration();
    second_date_text = pluralize("day", second_date_num);
  }else if(duration > dayDuration()){
    first_date_num = Math.floor(duration / dayDuration());
    first_date_text = pluralize("day", first_date_num);
    second_date_num = Math.floor(duration / hourDuration()) -
                      first_date_num * dayDuration() / hourDuration();
    second_date_text = pluralize("hour", second_date_num);
  }else{
    first_date_num = Math.floor(duration / hourDuration());
    first_date_text = pluralize("hour", first_date_num);
    second_date_num = Math.floor(duration / minuteDuration()) -
                      first_date_num * hourDuration() / minuteDuration();
    second_date_text = pluralize("minute", second_date_num);
  }

  updateAllDurationFields(first_date_num, first_date_text, second_date_num, second_date_text);
}

function updateAllDurationFields(date_1, text_1, date_2, text_2){
  animateDate("first_date_num", date_1);
  $("#first_date_text").text(text_1);
  animateDate("second_date_num", date_2);
  $("#second_date_text").text(text_2);
}

function animateDate(id, end){
  (new countUp(id,  parseInt($("#" + id + "").text()), end, 0, 1, {})).start();
}

function updatePrivewPrizeField(index){
  prize_preview = $(".prize_description p").eq(index);
  text = $(".prize_field").eq(index).val();
  if(text.length == 0 ){
    text = "Prize description will appear here";
    prize_preview.addClass("placeholder_text");
  }else{
    prize_preview.removeClass("placeholder_text");
  }
  prize_preview.text(text);
}

function updatePreivewOtherInfo(){
  text = $("#raffle_other_info").val();
  if(text.length == 0 ){
    text = $("#raffle_other_info").attr("placeholder");
    $(".other_info_row").addClass("placeholder_text");
  }else{
    $(".other_info_row").removeClass("placeholder_text");
  }
  $(".other_info_row").text(text);
}

function removePrize(index){
  prize = $(".prize_section").eq(index);
  prize_preview = $(".prize_row").eq(index);
  if( $(".prize_section").length == 1 ){
    prize.find("textarea").val("");
    updatePrivewPrizeField(index);
  }else{
    prize.remove();
    prize_preview.remove();
  }
}

function clearAll(){
  //clear dates
  $("#raffle_starts_at").val("");
  $("#raffle_ends_at").val("");
  //update dates in preview
  validateStartDate();
  validateEndDate();
  //remove all prizes except first
  $(".prize_section:gt(0)").remove();
  //set first empty
  $(".prize_field").val("");
  //delete prizes from preview
  $(".prize_row:gt(0)").remove();
  //set first empty
  updatePrivewPrizeField(0);
  //clear other info
  $("#raffle_other_info").val( $("#raffle_other_info").attr("placeholder") );
  updatePreivewOtherInfo();
  $("form textarea, form input").change();
}

function clearAllDialog(){
  $( "#clear_dialog" ).dialog({
    resizable: false,
    height:200,
    width: 400,
    modal: true,
    buttons: {
      "Confirm": function() {
        $( this ).dialog( "close" );
        clearAll();
        saveDraft();
        rebindPrizeEvents();
      },
      Cancel: function() {
        $( this ).dialog( "close" );
      }
    }
  });
  $( "#clear_dialog" ).dialog( "close" );
}

/*********************Live************************/

function disableForm(){
  $("form[class$='_raffle'] :input").attr("disabled", "disabled");
}

function enableForm(){
  $("form[class$='_raffle'] :input").removeAttr("disabled");
}

function liveEditButtons(){
  $("#edit_or_save").text("Save");
  $("#progress_or_cancel").text("Cancel").removeAttr("disabled");
  $(".finish_button").css("display", "none");
}

function liveShowButtons(){
  $("#edit_or_save").text("Edit");
  $("#progress_or_cancel").text("In progress").attr("disabled", "disabled");
  $(".finish_button").css("display", "");
}

function turnLiveEdit(){
  enableForm();
  liveEditButtons();
  window.prizeFormStatus = 'live_edit';
}

function turnLiveShow(){
  disableForm();
  liveShowButtons();
  window.prizeFormStatus = 'live_show';
}

function updateRaffle(){
  $("form[class$='_raffle']").attr("action", "/client_admin/prizes")
                             .attr("data-remote", "true")
                             .submit();
}

function makeConfirmButton(button){
  button.addClass("confirmation").text( button.attr("data-confirm-message") );
}
