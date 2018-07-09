import AirFactory from './AirFactory';
import TestDatabaseFetcher from './TestDatabaseFetcher';

Cypress.Commands.add("resetDb", () => {
  TestDatabaseFetcher.destroyAll();
});

Cypress.Commands.add("factoryCreate", (model, data) => {
  const factoryParams = AirFactory.createParams(model, data);
  // return AirFactory.createModels(TestDatabaseFetcher.post(factoryValues));
});

Cypress.Commands.add("factoryCreateMany", (model, amount, data) => {
  if (typeof amount !== "number") { throw "Invalid arguments -- (model, amount, data)" }
  const factoryValues = AirFactory.createRakeDigest(model, data, amount);
  // for (var i = 0; i < amount; i++) {
  //   cy.exec(`RAILS_ENV=test rake "cypress:factory[${factoryValues[i]}]"`)
  // }
});
