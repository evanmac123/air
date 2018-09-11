context('Archive Tile status nav functionality', () => {
  beforeEach(function() {
    cy.factoryCreate('demo').as('demo')
    .then(demo => {
      cy.factoryCreate('user:clientAdmin', {
        addActions: ['login'],
        associations: { demo },
      }).as('user')
      cy.factoryCreate('tile', 2, {
        status: 'archive',
        associations: { demo },
      }).as('tiles');
    });
  });

  describe('basic tile functionality', () => {
    it('displays the tiles in plan properly', function() {
      cy.visit('/client_admin/tiles');
      cy.contains('Archive').children('span').should('have.text', '(2)').click();

      cy.get(`#single-tile-${this.tiles[0].id}`).should('be.visible');
      cy.get(`#single-tile-${this.tiles[1].id}`).should('be.visible');
      cy.get(`#single-tile-${this.tiles[0].id} .unique_views`).should('have.text', '\n        \n        0\n    ');
      cy.get(`#single-tile-${this.tiles[0].id} .views`).should('have.text', '\n      \n      0\n    ');
      cy.get(`#single-tile-${this.tiles[0].id} .completions`).should('have.text', '\n      \n      0\n    ');
      cy.get(`#single-tile-${this.tiles[1].id} .unique_views`).should('have.text', '\n        \n        0\n    ');
      cy.get(`#single-tile-${this.tiles[1].id} .views`).should('have.text', '\n      \n      0\n    ');
      cy.get(`#single-tile-${this.tiles[1].id} .completions`).should('have.text', '\n      \n      0\n    ');

      cy.get(`[data-tile-container-id=${this.tiles[0].id}] [data-action="unarchive"]`).invoke('show').click();

      cy.get('.sweet-alert.airbo.showSweetAlert.visible h2').should('have.text', 'Are you sure about that?');
      cy.get('.sa-button-container button.cancel').click();

      cy.get(`#single-tile-${this.tiles[0].id}`).should('be.visible');
      cy.get(`#single-tile-${this.tiles[1].id}`).should('be.visible');

      cy.get(`[data-tile-container-id=${this.tiles[0].id}] [data-action="unarchive"]`).invoke('show').click();
      cy.wait(500);
      cy.get('.sa-confirm-button-container button.confirm').click();

      cy.get(`#single-tile-${this.tiles[0].id}`).should('be.hidden');
      cy.get(`#single-tile-${this.tiles[1].id}`).should('be.visible');

      cy.contains('Archive').children('span').should('have.text', '(1)');
      cy.contains('Live').children('span').should('have.text', '(1)').click();

      cy.get(`#single-tile-${this.tiles[0].id}`).should('be.visible');
    });
  });
});
