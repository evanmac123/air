module PagesHelper
  def advantages
    [
      ["Wellness", "Open Enrollment", "Onboarding", "Learning & Development"],
      ["Health Care Reform", "Retirement", "Safety", "Leadership Updates"],
      ["Employee Research", "Events", "Social Recruting", "Financial Education"],
      ["Sustainability", "Consumerism", "Philanthropy", "Compliance"]
    ]
  end

  def tile_features
    [
      {
        title: "Visually interesting", 
        desc: "An image to capture attention."
      },
      {
        title: "Easy to understand",
        desc: "375 characters of content."
      },
      {
        title: "Links to increase participation",
        desc: "Like vendor sites and intranets."
      },
      {
        title: "Interactive",
        desc: "Employee earns points for engaging. " + "\n" +
              "You can add prices and leaderboards."
      }
    ]
  end
end