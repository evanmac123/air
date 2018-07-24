context('Plan Tile status nav functionality', () => {
  beforeEach(function() {
    cy.factoryCreate('demo').as('demo')
    .then(demo => {
      cy.factoryCreate('user:clientAdmin', {
        addActions: ['login'],
        associations: { demo },
      }).as('user')
      cy.factoryCreate('tile', {
        plan_date: '1/22/2099',
        status: 'plan',
        associations: { demo },
      }).as('tiles');
    });
  });

  describe('basic tile functionality', () => {
    it('displays the tiles in plan properly', function() {
      cy.visit('/client_admin/tiles');
    });
  });
});
