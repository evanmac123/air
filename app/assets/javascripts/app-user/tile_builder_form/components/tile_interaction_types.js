var Airbo = window.Airbo || {};

Airbo.TileBuilderInteractionConfig = (function() {
  var interactionTypes = {
    action: {
      read_tile: {
        name: "Read Tile",
        question: "Points for reading tile",
        questionPlaceholder: "Add prompt",
        maxLength: 50,
        answers: ["I read it"],
        minResponses: 1,
        maxResponses: 1
      },
      take_action: {
        name: "Take Action",
        question: "Points for taking action",
        questionPlaceholder: "Add prompt",
        maxLength: 50,
        answers: ["I did it"],
        minResponses: 1,
        maxResponses: 1
      },
      read_article: {
        name: "Read Article",
        question: "Points for reading article",
        questionPlaceholder: "Add prompt",
        maxLength: 50,
        answers: ["I read it"],
        minResponses: 1,
        maxResponses: 1
      },
      share_on_social_media: {
        name: "Share On Social Media",
        question:
          "Points for sharing on social media (e.g., Facebook, Twitter)",
        questionPlaceholder: "Add prompt",
        maxLength: 50,
        answers: ["I shared"],
        minResponses: 1,
        maxResponses: 1
      },
      visit_web_site: {
        name: "Visit Web Site",
        question: "Points for visiting web site",
        questionPlaceholder: "Add prompt",
        maxLength: 50,
        answers: ["I visited"],
        minResponses: 1,
        maxResponses: 1
      },
      watch_video: {
        name: "Watch Video",
        question: "Points for watching video",
        questionPlaceholder: "Add prompt",
        maxLength: 50,
        answers: ["I watched"],
        minResponses: 1,
        maxResponses: 1
      },
      custom: {
        name: "Custom...",
        question: "Points for taking an action",
        questionPlaceholder: "Add prompt",
        maxLength: 50,
        answers: ["Add Action"],
        minResponses: 1,
        maxResponses: 1
      }
    },
    quiz: {
      true_false: {
        name: "True / False",
        question: null,
        questionPlaceholder: "Fill in statement",
        answers: ["True", "False"],
        extendable: false,
        wrongable: true,
        maxLength: 50,
        minResponses: 2,
        maxResponses: 2
      },
      multiple_choice: {
        name: "Multiple Choice",
        question: null,
        questionPlaceholder: "Ask a question",
        answers: ["Add Answer Option", "Add Answer Option"],
        extendable: true,
        wrongable: true,
        maxLength: 50,
        minResponses: 2,
        maxResponses: 100
      }
    },
    survey: {
      multiple_choice: {
        name: "Multiple Choice",
        question: null,
        questionPlaceholder: "Ask a question",
        answers: [
          "Add Answer Option",
          "Add Answer Option",
          "Add Answer Option"
        ],
        extendable: true,
        maxLength: 50,
        minResponses: 2,
        maxResponses: 100,
        freeResponse: true,
        allowAnonymous: true
      },
      free_response: {
        name: "Free Response",
        question: null,
        questionPlaceholder: "Ask a question",
        maxLength: 50,
        answers: ["Submit"],
        exceed: true,
        minResponses: 0,
        maxResponses: 0,
        allowAnonymous: true,
        builder: Airbo.FreeResponseAnswer
      },
      rsvp_to_event: {
        name: "RSVP To Event",
        question: "Will you be attending?",
        questionPlaceholder: "Add prompt",
        answers: ["Yes", "No", "Maybe"],
        extendable: false,
        maxLength: 50,
        minResponses: 3,
        maxResponses: 3
      },
      change_email: {
        name: "Change Email",
        question:
          "Would you like to change the email that you receive Airbo email notifications?",
        questionPlaceholder: "Add prompt",
        answers: ["Change my email", "Keep my current email"],
        minResponses: 2,
        maxResponses: 2,
        extendable: false,
        correctAnswerIndex: 0,
        maxLength: 50
      }
    }
  };

  function addInviteSpouseConfig() {
    if (Airbo.currentBoard.dependent_board_enabled) {
      interactionTypes.survey.invite_spouse = {
        name: "Invite Spouse",
        question: "Do you want to invite your spouse?",
        questionPlaceholder: "Add prompt",
        answers: [
          "I have a dependent and want to invite them",
          "I have a dependent but don't want to invite them",
          "I don't have a dependent"
        ],
        minResponses: 3,
        maxResponses: 3,
        extendable: false,
        correctAnswerIndex: 0
      };
    }
  }

  function addCustomInteractions() {
    addInviteSpouseConfig();
  }

  function interactions() {
    addCustomInteractions();
    return interactionTypes;
  }

  function interactionByType(type) {
    return interactions()[type];
  }

  function get(type, subtype) {
    return interactions()[type][subtype];
  }
  function interactionSet() {
    return interactions();
  }

  function defaultKeys() {
    return { type: "action", subtype: "read_tile" };
  }

  return {
    interactionSet: interactionSet,
    interaction: interactionByType,
    defaultKeys: defaultKeys,
    get: get
  };
})();
