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

TestDatabaseFetcher.post = params => {
  const key = Cypress.env('CLEANUP');
  cy.request({
    method: 'POST',
    url: `/cypress/test_database?key=${key}`,
    body: params
  })
    .then(standardResponseHandling);
};

export default TestDatabaseFetcher;
