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
      cy.contains('Home');
      cy.contains('About');
      cy.contains('Case Studies');
      cy.contains('Request Demo');
      cy.contains('Sign In');
      cy.contains(this.campaign.name);
    });

    it('loads campaigns tiles', function() {
      cy.contains(this.campaign.name).click();
    });
  });
});
