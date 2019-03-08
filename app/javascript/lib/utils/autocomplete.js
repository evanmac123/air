import * as $ from 'jquery';

const delayBeforeSend = 300; // How long of a delay must exist after typing before we send a request
let autocompleteInProgress = 0;
let autocompleteWaiting = 0;
let newCharsEntered = 0;
let watchdogRunning = 0;
let lastKeypress = 0;

function getAutocomplete(options) {
  const enteredText = $(`${options.callingDiv} #autocomplete`).val();
  if (enteredText.length > 2) {
    options.enteredText = enteredText; // eslint-disable-line
    $("#autocomplete_status").text("Searching ...");
    $.get("/invitation/autocompletion#index", options, (data) => {
      options = {}; // eslint-disable-line
      if (data === "") {
        $("#autocomplete_status").text("Hmmm...no match");
        $("#suggestions").hide();

        setTimeout(() => {
          if ($("#autocomplete_status").text() === "Hmmm...no match")
            $("#autocomplete_status").text("Please try again");
        }, 3000);
      } else {
        $("#autocomplete_status").text("Click on the person you want to invite:");
        $("#search_for_referrer #autocomplete_status").text("Click on the person who referred you:");
        $(".helper.autocomplete").fadeOut();
        $("#hide_me_while_selecting").hide();
        $("#bonus").fadeOut();
        $("#suggestions").show();
      }
      $("#suggestions").html(data);
      $(".invite-module").css("height", ($("#search_for_friends_to_invite").height() + 10));

      autocompleteInProgress = 0;
    });
  } else {
    $("#suggestions").html("");
    setTimeout(() => $('#suggestions').hide(), 1);
    setTimeout(() => $(".invite-module").css("height", ($("#search_for_friends_to_invite").height() + 10)), 1);

    // Yes, you must set this to zero even if you didn't run the function call
    autocompleteInProgress = 0;
    $("#autocomplete_status").text("3+ letters, please");
  }
  if (enteredText.length) {
    setTimeout(() => $('.helper.autocomplete').fadeOut(), 500);
  } else {
    setTimeout(() => $('.helper.autocomplete').fadeIn(), 500);
    $("#autocomplete_status").text("");
  }
}

function autocompleteIfNoneRunning(options) {
  // Only allow one request at a time
  // Allow queue size of one
  if (autocompleteWaiting) { return; }

  if (autocompleteInProgress) {
    // put this one in the queue to try again in one second
    autocompleteWaiting = 1;
    setTimeout(() => {
      autocompleteWaiting = 0;
      autocompleteIfNoneRunning(options);
    }, 1000);
  } else {
    // Nothing is running or waiting, so send the ajax request for autocompletions
    // Note the tiny delay so that the most recent typed letter is included
    autocompleteInProgress = 1;
    setTimeout(() => { getAutocomplete(options); }, 50);
  }
}

function autocompleteIfNewCharsEnteredAndNoKeypressesRecently(options) {
  if (newCharsEntered && (new Date().getTime() - lastKeypress > delayBeforeSend)) {
    newCharsEntered = 0;
    autocompleteIfNoneRunning(options);
  }
}

function watchDogSender(options) {
  // This function repeats every 100ms until we stop the watchdog
  if (watchdogRunning) {
    autocompleteIfNewCharsEnteredAndNoKeypressesRecently(options);
    setTimeout(() => {
      watchDogSender(options);
    }, 100);
  }
}

function startWatchDog(options) {
  if (!watchdogRunning) {
    watchdogRunning = 1;
    watchDogSender(options);
  }
}

function stopWatchDog() {
  watchdogRunning = 0;
}

function markForSend() {
  newCharsEntered = 1;
  lastKeypress = new Date().getTime();
}
