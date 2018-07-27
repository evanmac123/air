import AirFactory from './AirFactory';

const standardResponseHandling = resp => {
  if (resp.body.status === 'error') { throw `Error: ${resp.body.message}` }
  return resp.body;
};

const TestDatabaseFetcher = {};

TestDatabaseFetcher.destroyAll = () => {
  const key = Cypress.env('CLEANUP');
  cy.request('DELETE', `/cypress/test_database/0?key=${key}`)
    .then(standardResponseHandling);
};

TestDatabaseFetcher.createFromFactory = params => {
  const key = Cypress.env('CLEANUP');
  cy.request({
    method: 'POST',
    url: `/cypress/test_database?key=${key}`,
    body: params
  })
    .then(resp => {
      if (resp.body.status === 'error') { throw `Error: ${resp.body.message}` }
      return AirFactory.createModels(params[0].model, resp.body, params.length);
    });
};

TestDatabaseFetcher.getCsrfToken = () => {
  const key = Cypress.env('CLEANUP');
  return cy.request('GET', `/cypress/test_database/csrf_token?key=${key}`)
    .then(standardResponseHandling);
}

export default TestDatabaseFetcher;
