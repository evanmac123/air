//= require ./standard_answer

/*
 * Above required statement needed in order for StandardAnswer to be included during precomplilation
 * Currently this class doesn't provide any additional customized behavior but
 * is retained for future customization
 *
 */
var Airbo = Airbo || {};

Airbo.CustomFormAnswer = Object.create(Airbo.StandardAnswer);

/*
 * Do the customizations here
 * add to TileBuilderInteractionConfig: custom_form: {
        name: "Form",
        question: "Ask a question",
        maxLength: 50,
        answers: ["Change my phone", "Keep my current phone"],
        exceed: true,
        minResponses: 2,
        maxResponses: 2,
        builder: Airbo.CustomFormAnswer,
        extendable: false,
      }
 */
