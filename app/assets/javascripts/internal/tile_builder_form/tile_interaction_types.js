var Airbo = window.Airbo || {};


Airbo.TileBuilderInteractionConfig = (function(){
  var interactions =  {
    action:{
      take_action: {
        answerType: "action",
        name: "Take Action",
        question: "Points for taking action",
        maxLength: 50,
        answers: ["I did it"],
        minResponses: 1,
        maxResponses: 1,
      },
      read_tile: {
        answerType: "action",
        name: "Read Tile",
        question: "Points for reading tile",
        maxLength: 50,
        answers: ["I read it"],
        minResponses: 1,
        maxResponses: 1,
      },
      read_article: {
        answerType: "action",
        name: "Read Article",
        question: "Points for reading article",
        maxLength: 50,
        answers: ["I read it"],
        minResponses: 1,
        maxResponses: 1,
      },
      share_on_social_media : {
        answerType: "action",
        name: "Share On Social Media",
        question: "Points for sharing on social media (e.g., Facebook, Twitter)",
        maxLength: 50,
        answers: ["I shared"],
        minResponses: 1,
        maxResponses: 1,
      },
      visit_web_site: {
        answerType: "action",
        name: "Visit Web Site",
        question: "Points for visiting web site",
        maxLength: 50,
        answers: ["I visited"],
        minResponses: 1,
        maxResponses: 1,
      },
      watch_video: {
        answerType: "action",
        name: "Watch Video",
        question: "Points for watching video",
        maxLength: 50,
        answers: ["I watched"],
        minResponses: 1,
        maxResponses: 1,
      },
      custom: {
        answerType: "action",
        name: "Custom...",
        question: "Points for taking an action",
        maxLength: 50,
        answers: ["Add Action"],
        minResponses: 1,
        maxResponses: 1,
      },
      free_form: {
        answerType: "action_free_form",
        name: "Free Form Text ",
        question: "Ask question requiring a free form response",
        maxLength: 500,
        answers: ["Submit my response"],
        exceed: true,
        minResponses: 1,
        maxResponses: 1,
      }
    },

    quiz: {
      true_false: {
        answerType: "quiz",
        name: "True / False",
        question: "Fill in statement",
        answers: ["True",  "False"],
        extendable: false,
        wrongable: true,
        maxLength: 50,
        minResponses: 2,
        maxResponses: 2,
      },
      multiple_choice: {
        answerType: "quiz",
        name: "Multiple Choice",
        question: "Ask a question",
        answers: ["Add Answer Option",  "Add Answer Option"],
        extendable: true,
        wrongable: true,
        maxLength: 50,
        minResponses: 2,
        maxResponses: 100,
      }
    },

    survey : {
      multiple_choice: {
        answerType: "survey",
        name: "Multiple Choice",
        question: "Add question",
        answers: ["Add Answer Option", "Add Answer Option"],
        extendable: true,
        maxLength: 50,
        minResponses: 2,
        maxResponses: 100,
        freeResponse: true
      },
      rsvp_to_event : {
        answerType: "survey",
        name: "RSVP To Event",
        question: "Will you be attending?",
        answers: ["Yes", "No", "Maybe"],
        extendable: false, 
        maxLength: 50,
        minResponses: 3,
        maxResponses: 3,
      },
      change_email: {
        answerType: "survey",
        name: "Change Email",
        question: "Would you like to change the email that you receive Airbo email notifications?",
        answers: ["Change my email", "Keep my current email"],
        minResponses: 2,
        maxResponses: 100,
        extendable: true,
        maxLength: 50,
      },

      invite_spouse: {
        answerType: "survey",
        name: "Invite Spouse",
        question: "Do you want to invite your spouse?",
        answers: [
          "I have a dependent and want to invite them", 
          "I have a dependent but don't want to invite them", "I don't have a dependent"
        ],
        minResponses: 3,
        maxResponses: 3,
        extendable: false
      },
    }
  }


  function interactionByType(type){
    return interactions[type];
  }

  function get(type, subtype){
    return interactions[type][subtype];
  }
  function interactionSet(){
    return interactions;
  }

  function defaultKeys(){
    return {type:"action",subtype: "take_action"}
  }

  return {
    interactionSet: interactionSet,
    interaction: interactionByType,
    defaultKeys: defaultKeys,
    get: get
  };

}())



