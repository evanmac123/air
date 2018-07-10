context('Landing page', () => {
  beforeEach(function() {
    let campaign;
    cy.factoryCreate('campaign', {
      active: true,
      public_explore: true,
    }).as('campaign')
      .then(campaign => {
        cy.factoryCreate('tile', 3, {
          is_public: true,
          associations: { campaign }
        }).as('tiles');
      })
    cy.visit('/explore');
  });

  describe('Visits the explore page as guest user', () => {
    it('contains guest user base navigation', function() {
      cy.contains('Home').should('have.attr', 'href', '/');
      cy.contains('About').should('have.attr', 'href', '/about');
      cy.contains('Case Studies').should('have.attr', 'href', '/case_studies');
      cy.contains('Sign In').should('have.attr', 'href', '/sign_in');
    });

    it('loads campaigns tiles', function() {
      cy.get('.campaign-card').children('img')
        .should('length', 3)
        .first()
        .should('have.attr', 'src', this.tiles[0].remote_media_url);

      cy.get('.card-title')
        .should('have.text', this.campaign.name)
        .click();

      cy.get('.explore-sub-page-header')
        .should('have.text', this.campaign.name);

      cy.get('.campaign-description').children('p').first()
        .should('have.text', this.campaign.description);

      this.tiles.forEach(tile => {
        const created_split = tile.created_at.split('-')
        const created_at = `${created_split[1]}/${created_split[2].split('T')[0]}/${created_split[0]}`
        cy.get(`#single-tile-${tile.id} .tile_thumbnail_image`).children('img').first()
          .should('have.attr', 'src', tile.remote_media_url);
        cy.get(`#single-tile-${tile.id} .activation_dates`).children('span').first()
          .should('have.text', created_at);
        cy.get(`#single-tile-${tile.id} .headline`).children('div').first()
          .should('have.text', tile.headline);
      });
    });
  });
});
