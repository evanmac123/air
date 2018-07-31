context('Plan Tile status nav functionality', () => {
  beforeEach(function() {
    cy.factoryCreate('demo').as('demo')
    .then(demo => {
      cy.factoryCreate('user:clientAdmin', {
        addActions: ['login'],
        associations: { demo },
      }).as('user')
      cy.factoryCreate('tile', {
        status: 'plan',
        addActions: ['run: Tile.first.update(plan_date: "1/1/2099")'],
        associations: { demo },
      }).as('plannedTile');
      cy.factoryCreate('tile', {
        status: 'plan',
        associations: { demo },
      }).as('unplannedTile');
    });
  });

  describe('basic tile functionality', () => {
    it('displays the tiles in plan properly', function() {
      cy.visit('/client_admin/tiles');
      cy.contains('Plan').children('span').should('have.text', '(2)');

      cy.get(`#single-tile-${this.unplannedTile.id} .activation_dates span`).should('have.text', 'Unplanned');
      cy.get(`#single-tile-${this.plannedTile.id} .activation_dates span`).should('have.text', 'January 1');
    });
  });
});
