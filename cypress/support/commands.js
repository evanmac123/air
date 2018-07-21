import AirFactory from './AirFactory';
import TestDatabaseFetcher from './TestDatabaseFetcher';

Cypress.Commands.add("resetDb", () => {
  TestDatabaseFetcher.destroyAll();
});

Cypress.Commands.add("factoryCreate", (model, amount, data) => {
  if (typeof amount !== "number") {
    data = amount;
    amount = 1;
  }
  const factoryParams = AirFactory.createParams(model, data, amount);
  return TestDatabaseFetcher.createFromFactory(factoryParams);
});

Cypress.Commands.add("insertCsrf", () => {
  TestDatabaseFetcher.getCsrfToken().then(resp => {
    Cypress.$("head").append(`<meta name="csrf-token" content="${resp.token}">`);
  });
});
