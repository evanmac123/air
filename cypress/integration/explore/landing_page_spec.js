context('Landing page', () => {
  beforeEach(() => {
    cy.factoryCreate('campaign', {
      name: 'Test Campaign',
      description: 'Campaign generated for E2E testing',
      active: true,
      slug: 'test-campaign',
      ongoing: false,
      icon_link: '',
      private_explore: false,
      public_explore: true,
      color: null,
    });
    // cy.factoryCreateMany('tile', 3, {
    //   associations: {
    //     campaign: {slug: 'test-campaign'},
    //   },
    // });
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

    it('loads campaigns tiles', () => {
      cy.contains('Test Campaign').click();
    });
  });
});
