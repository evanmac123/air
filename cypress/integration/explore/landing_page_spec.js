context('Landing page', () => {
  beforeEach(function() {
    cy.factoryCreate('campaign', {
      active: true,
      public_explore: true,
    }).as('campaign');
    // cy.factoryCreate('tile', 3, {
    //   associations: {
    //     campaign: this.campaign.id,
    //   },
    // }).as('tiles');
    cy.visit('/explore');
  });

  describe('Visits the explore page as guest user', () => {
    it('contains guest user base navigation', () => {
      cy.contains('Home');
      cy.contains('About');
      cy.contains('Case Studies');
      cy.contains('Request Demo');
      cy.contains('Sign In');
    });

    it('loads campaigns tiles', function() {
      cy.contains(this.campaign.name).click();
    });
  });
});
