const campaignPath = campaign => (
  `/explore/campaigns/${campaign.id}-${campaign.name.toLowerCase().replace(/[^A-Za-z0-9 ]/g, '').replace(/\s+/g,"-")}`
);

const getNextTile = (tiles, data) => {
  for (var i = 0; i < tiles.length; i++) {
    if (tiles[i].id === data) { return tiles[i]; }
  }
};

const testAllById = (items, declaration, expected) => {
  items.forEach(item => { cy.get(`#${item.id}`).should(declaration, expected) });
};

context('Landing page', () => {
  beforeEach(function() {
    cy.factoryCreate('campaign', {
      active: true,
      public_explore: true,
    }).as('campaign')
      .then(campaign => {
        cy.factoryCreate('tile', 3, {
          is_public: true,
          associations: { campaign }
        }).as('tiles');
      });
  });

  describe('Visits the explore page as guest user', () => {
    beforeEach(function() {
      cy.visit('/explore');
    });

    it('contains guest user base navigation', function() {
      cy.contains('Home').should('have.attr', 'href', '/');
      cy.contains('About').should('have.attr', 'href', '/about');
      cy.contains('Case Studies').should('have.attr', 'href', '/case_studies');
      cy.contains('Sign In').should('have.attr', 'href', '/sign_in');
    });

    it('loads campaigns tiles', function() {
      let nextTile;

      cy.get('.campaign-card').children('img')
        .should('length', 3)
        .first()
        .should('have.attr', 'src', this.tiles[0].remote_media_url);


      cy.get('.card-title')
        .should('have.text', this.campaign.name)
        .click();

      cy.contains('Copy Campaign').should('not.exist');

      cy.location('pathname').should('eq', campaignPath(this.campaign));

      cy.get('.explore-sub-page-header')
        .should('have.text', this.campaign.name);

      cy.get('.campaign-description').children('p').first()
        .should('have.text', this.campaign.description);

      cy.get('.tile_buttons').should('not.exist');

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

      cy.get(`#single-tile-${this.tiles[0].id} .tile_thumb_link_explore`).click();
      cy.get('.tile_full_image.loading').should('have.class', 'loading');
      cy.get('.tile_headline.content_sections').should('have.text', this.tiles[0].headline);
      cy.get('.tile_supporting_content.content_sections').children('p').first()
        .should('have.text', this.tiles[0].supporting_content);
      cy.get('.tile_question.content_sections').should('have.text', this.tiles[0].question);

      cy.get('#next_tile').should($next_tile => {
        nextTile = getNextTile(this.tiles, $next_tile.data('tile-id'));
        expect($next_tile.attr('href')).to.equal(`/explore/tile/${nextTile.id}`);
        expect($next_tile.attr('href')).to.not.equal(`/explore/tile/${this.tiles[0].id}`);
      }).click()
        .get('.tile_holder').should($tile_holder => {
          nextTile = getNextTile(this.tiles, $tile_holder.data('current-tile-id'));
          const $text_container = $tile_holder.children('div').first().children('div.tile_main').children('div.tile_texts_container');
          expect($text_container.children('.tile_headline.content_sections').text())
            .to.equal(nextTile.headline);
          expect($text_container.children('.tile_supporting_content.content_sections').children('p').first().text())
            .to.equal(nextTile.supporting_content);
        });
    });

    it('navigates with correct urls and state', function() {
      cy.location('pathname').should('eq', '/explore');

      cy.get('.card-title').click();

      cy.location('pathname').should('eq', campaignPath(this.campaign));

      // clicking back
      cy.go(-1);

      cy.location('pathname').should('eq', '/explore');

      // clicking forward
      cy.go(1);

      cy.location('pathname').should('eq', campaignPath(this.campaign));

      cy.visit(campaignPath(this.campaign));

      cy.get('.explore-sub-page-header')
      .should('have.text', this.campaign.name);

      cy.get('.campaign-description').children('p').first()
      .should('have.text', this.campaign.description);
    });

    it('navigates to campaign board from url without cache', function() {
      cy.visit(campaignPath(this.campaign));

      cy.get('.explore-sub-page-header')
      .should('have.text', this.campaign.name);

      cy.get('.campaign-description').children('p').first()
      .should('have.text', this.campaign.description);
    });
  });


  describe('Visits the explore page as client admin', () => {
    beforeEach(function() {
      cy.factoryCreate('user:clientAdmin', { addActions: ['login'] });
      cy.visit('/explore');
    });

    it('loads campaigns with copy functionality', function() {
      cy.insertCsrf();
      cy.get('.campaign-card').children('img')
        .should('length', 3)
        .first()
        .should('have.attr', 'src', this.tiles[0].remote_media_url);

      cy.get('.card-title')
        .should('have.text', this.campaign.name)
        .click();

      cy.location('pathname').should('eq', campaignPath(this.campaign));

      testAllById(this.tiles, 'have.text', 'Copy');

      cy.contains('Copy Campaign').should('exist').and('have.class', 'button')
        .click()
        .then($copyButton => { expect($copyButton.text()).to.eq('Campaign Copied') });

      testAllById(this.tiles, 'have.text', 'Copied');

      cy.wait(2000);

      cy.contains('Edit').click();

      cy.location('pathname').should('eq', '/client_admin/tiles');
      cy.wait(2000);
      cy.reload();

      this.tiles.forEach(tile => { cy.contains(tile.headline).should('exist') });
    });

    it('loads campaigns wihout copy functionality', function() {
      cy.factoryCreate('campaign', {
        ongoing: true,
        active: true,
        public_explore: true,
      }).then(campaign => {
        cy.factoryCreate('tile', {
          is_public: true,
          associations: { campaign }
        });
        cy.reload();
        cy.contains(campaign.name)
          .should('have.text', campaign.name)
          .click();

        cy.location('pathname').should('eq', `/explore/campaigns/${campaign.id}-${campaign.name.toLowerCase().replace(/\s+/g,"-")}`);

        cy.contains('Copy Campaign').should('not.exist');
      });
    });

    it('copies tiles individually from show', function() {
      cy.visit(campaignPath(this.campaign));

      cy.get(`#single-tile-${this.tiles[0].id} .tile_thumb_link_explore`).click();

      for (let i = 0; i < 3; i++) {
        cy.get('.copy_to_board').should('exist')
          .click()
          .should('have.text', '\n      \n      Copied\n');

        cy.get('#next_tile').click();
      }

      cy.wait(2000);
      cy.visit('/client_admin/tiles#tab-plan');

      cy.wait(2000);
      cy.reload();

      this.tiles.forEach(tile => { cy.contains(tile.headline).should('exist') });
    });

    it('copies tiles individually from campaign', function() {
      cy.visit(campaignPath(this.campaign));
      cy.insertCsrf();

      this.tiles.forEach(tile => {
        cy.get(`#${tile.id}`).should('have.text', 'Copy').click()
          .should('have.text', 'Copied');
      });

      cy.wait(2000);
      cy.visit('/client_admin/tiles#tab-plan');

      cy.wait(2000);
      cy.reload();

      this.tiles.forEach(tile => { cy.contains(tile.headline).should('exist') });
    });
  });

  describe('Visits the explore page as client admin with private campaigns', () => {
    beforeEach(function() {
      cy.factoryCreate('demo').as('demo')
        .then(demo => {
          cy.factoryCreate('campaign', {
            active: true,
            private_explore: true,
            associations: { demo: demo },
          }).as('privateCampaign')
          .then(campaign => {
            cy.factoryCreate('tile', 3, {
              associations: { campaign },
            }).as('privateTiles');
          });
        })
    });

    it('displays private campaigns for client admin', function() {
      cy.visit('/explore');

      cy.contains(this.campaign.name).should('exist');
      cy.contains(this.privateCampaign.name).should('not.exist');

      cy.factoryCreate('user:clientAdmin', {
        addActions: ['login'],
        associations: { demo: this.demo }
      });
      cy.visit('/explore');

      cy.contains(this.campaign.name).should('exist');
      cy.contains(this.privateCampaign.name).should('exist');
    });

    it('does not display private campaigns for guests', function() {
      cy.visit('/explore');

      cy.contains(this.campaign.name).should('exist');
      cy.contains(this.privateCampaign.name).should('not.exist');
    });
  });
});
