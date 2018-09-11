context('Live Tile status nav functionality', () => {
  beforeEach(function() {
    cy.factoryCreate('demo').as('demo')
    .then(demo => {
      cy.factoryCreate('user:clientAdmin', {
        addActions: ['login'],
        associations: { demo },
      }).as('user')
      cy.factoryCreate('tile', 2, {
        status: 'active',
        associations: { demo },
      }).as('tiles');
    });
  });

  describe('basic tile functionality', () => {
    it('displays the tiles in plan properly', function() {
      cy.visit('/client_admin/tiles');
      cy.contains('Live').children('span').should('have.text', '(2)').click();

      cy.get(`#single-tile-${this.tiles[0].id}`).should('be.visible');
      cy.get(`#single-tile-${this.tiles[1].id}`).should('be.visible');

      cy.get(`[data-tile-container-id=${this.tiles[0].id}] [data-action="archive"]`).invoke('show').click();
      cy.get(`#single-tile-${this.tiles[0].id}`).should('be.hidden');
      cy.get(`#single-tile-${this.tiles[1].id}`).should('be.visible');

      cy.contains('Live').children('span').should('have.text', '(1)');
      cy.contains('Archive').children('span').should('have.text', '(1)');

      cy.get(`[data-tile-container-id=${this.tiles[1].id}] [data-action="archive"]`).invoke('show').click();
      cy.get(`#single-tile-${this.tiles[0].id}`).should('be.hidden');
      cy.get(`#single-tile-${this.tiles[1].id}`).should('be.hidden');

      cy.contains('Live').children('span').should('have.text', '(0)');
      cy.contains('Archive').children('span').should('have.text', '(2)').click();

      cy.get(`#single-tile-${this.tiles[0].id}`).should('be.visible');
      cy.get(`#single-tile-${this.tiles[1].id}`).should('be.visible');
    });
  });
});
