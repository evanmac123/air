class TutorialStep < Struct.new(:index, :show_introduction, :title, :instruct, :highlighted, :x, :y, :position, :arrow_dir, :flash_margin_left, :show_next_button, :show_finish_button)
  first_name = Tutorial.example_search_name.split(" ").first

  STEP_DEFINITIONS = {
    0 => {
      show_introduction: true
    },
    1 => {
      title: "1. Click It!",
      instruct: "Click to open the tile and earn points for learning about your benefits",
      highlighted: '#tile-thumbnail-0', # The sample tile always has and id of 0
      x: 20,
      y: -66,
      position: "center right",
      arrow_dir: "left",
    },
    2 => {
      title: "2. Read for Points!",
      instruct: "Read the tile below, then enter the key word here for points.",
      highlighted: '#bar_command_wrapper',
      x: -3,
      y: 36 ,
      position: "center right",
      arrow_dir: "left",
      flash_margin_left: "355px",  # This is so any failure messages will be offset & thereby visible
    },
    3 => {
      title: "3. Dialogue Box",
      instruct: "This is where you'll get helpful info to guide you".html_safe,
      show_next_button: true,
      highlighted: '.flash-box',
      x: 20,
      y: 48,
      position: "center right",
      arrow_dir: "left",
    },
    4 => {
      title: "4. Make Connections",
      instruct: "Click DIRECTORY to find people you know",
      highlighted: '.nav-directory',
      x: -105,
      y: 15,
      position: "bottom center",
      arrow_dir: "top-right",
    },
    5 => {
      title: "5. Find Your Friends",
      instruct: "Just for practice, type \"<span class='offset'>#{first_name}</span>\", then click FIND!",
      highlighted: '#search_box_wrapper',
      x: -17,
      y: 15,
      position: "bottom center",
      arrow_dir: "top-left",
    },
    6 => {
      title: "6. Friend Them",
      instruct: "Click ADD TO FRIENDS to connect with #{first_name}",
      highlighted: '#directory_wrapper',
      x: 20,
      y: 230,
      position: "top right",
      arrow_dir: "left",
    },
    7 => {
      title: "7. See Your Profile",
      instruct: "Great! Now you're connected with Kermit. Click MY PROFILE to see him.",
      highlighted: '.nav-activity',
      x: 0,
      y: 15,
      position: "bottom center",
      arrow_dir: "top-center",
    },
    8 => {
      title: "8. Have Fun Playing!",
      instruct: "That's it! Now you know how to connect with friends and how to earn points.",
      show_finish_button: true,
      highlighted: '#following_wrapper',
      x: -20,
      y: 151,
      position: "top left",
      arrow_dir: "right",
    }
  }.freeze

  def initialize(index)
    self.index = index
    step_definition = STEP_DEFINITIONS[index]
    step_definition.each {|key, value| self[key] = value}
  end
end
