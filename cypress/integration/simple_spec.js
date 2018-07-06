describe("Visits the explore page as guest user", function() {
  it("contains guest user base navigation", function() {
    cy.visit("http://localhost:5555/explore")

    cy.contains("Home")
    cy.contains("About")
    cy.contains("Case Studies")
    cy.contains("Request Demo")
    cy.contains("Sign In")
  })

  it("loads campaigns tiles", function() {
    cy.visit("http://localhost:5555/explore")

    cy.contains("Benefits").click();
  })
})
