function addNewPrizeField() {
  initialPrize = $('.prize_section').eq(0);
  //clone from first prize
  prize_count = $(".prize_section").length
  var newPrize = initialPrize.clone()
                .find('.character-counter').remove().end()
                .find('.prize_field').val('').end();
  newPrizeField = newPrize.find('.prize_field');
  newPrize.appendTo('#prizes');
  addCharacterCounterFor(newPrizeField);
}

function todayDate(){
  return (new Date()).setHours(12,0,0,0); //today afternoon
}

function startDateInSeconds(){
  return Date.parse($("#raffle_starts_at").val() + " 12:00");
}

function endDateInSeconds(){
  return Date.parse($("#raffle_ends_at").val() + " 12:00");
}

function endDate(){
  return (new Date($("#raffle_ends_at").val() + " 12:00"));
}

function startDate(){
  return (new Date($("#raffle_starts_at").val() + " 12:00"));
}

function disableEndDate(){
  return $("#raffle_ends_at").attr("disabled", "disabled").val("");
}

function enableEndDate(){
  return $("#raffle_ends_at").removeAttr("disabled");
}

function validateStartDate(){
  start_date = startDateInSeconds();
  end_date = endDateInSeconds();
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

  updatePreviewEndDate();
  updatePreviewDuration();
}

function validateEndDate(){
  end_date = endDateInSeconds();
  start_date = startDateInSeconds();

  if(end_date <= start_date){
    $("#raffle_ends_at").val("");
  }

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
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  return months[date.getMonth()];
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
  return endDate() - startDate();
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
  $(".big_date_num").text(date_1);
  $(".big_date_text").text(text_1);
  $(".small_date_num").text(date_2);
  $(".small_date_text").text(text_2);
}