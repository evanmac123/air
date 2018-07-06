import AirFactory from './AirFactory';

Cypress.Commands.add("resetDb", () => {
  cy.request('DELETE', 'http://localhost:5555/cypress_cleanup?key=a9335e2d32f2242584858b6676b39cc5859356cb4813b2c99fbeb18c3fcce36f33ccb5f18d9ba1c5c718590b55251164ac18594a952b4377c8c09bf38ef43452')
})

Cypress.Commands.add("factoryCreate", (model, data) => {
  const factoryValues = AirFactory.createRakeDigest(model, data)
  cy.exec(`RAILS_ENV=test rake "cypress:factory[${factoryValues}]"`)
})

Cypress.Commands.add("factoryCreateMany", (model, amount, data) => {
  if (typeof amount !== "number") { throw "Invalid arguments -- (model, amount, data)" }
  const factoryValues = AirFactory.createRakeDigest(model, data, amount)
  // for (var i = 0; i < amount; i++) {
  //   cy.exec(`RAILS_ENV=test rake "cypress:factory[${factoryValues[i]}]"`)
  // }
})
