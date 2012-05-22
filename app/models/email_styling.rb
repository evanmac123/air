class EmailStyling
  attr_reader :image_url, :table_width
  
  def initialize(host_url)
    @image_url = host_url
    @green = "#89c440"
    @grey_background = "#999999"
    @main_border_grey = "#717171"
    @top_light_grey = "#f0f0f0"
    @inner_width = 546
    @table_width = 602
    @small_font_size = "12px"
    @medium_font_size = "12px"
    @bright_green = "#39b149"
    @font_def = "font-family: helvetica, arial, sans-serif; "
    @grey_text_def = "color: #7d7d7d; "
    @side_borders_def = "border-left: 1px solid #{@grey_background}; border-right: 1px solid #{@grey_background};"
    @table_reset = "border-collapse: collapse; border-spacing: 0;"
    @nearly_white_def = "color: #e1e1e1;"
  end
    
  def paragraph
    "background: url('#{@image_url}/images/justtree.png')"
  end
  
  def masthead_top_shim
    "width: 600px; height: 25px; background: #{@grey_background };"
  end
  
  def masthead_left
      "background: #{@green}"
  end
  
  def corner
    "width: 9px; height: 8px;"
  end
  
  def table
    "#{@table_reset}width: #{@table_width};"
  end
  
  def table_hash
    {:align => :center, :cellpadding => 0, :cellspacing => 0, :border => 0, :style => table}
  end
      
  def table_reset_hash
    {style: @table_reset}
  end
  
  def table_reset_hash_set_width
    table_reset_hash.merge(width: @inner_width)
  end
  
  def table_reset_hash_full_width
    table_reset_hash.merge(width: "100%")
  end
  
  def between_corners
    "width: 578px; border-top: 1px solid #{@main_border_grey};"
  end
  
  
  def top_bar
    "background: #{@grey_background};"
  end
  
  def footer
    "background: #{@grey_background}; padding-top: 20px; padding-bottom: 20px;"
  end
  
  def body_hash
    {:style => "#{@side_borders_def}background: #{@top_light_grey}; padding-left: 27px; padding-right: 27px; "}
  end
  
  def bottom_body_hash
    {:style => "#{@side_borders_def}background: white; padding-left: 27px; padding-right: 27px; "}
  end
  
  def base_hash
    {:style => "background: #{@grey_background}; height: 100%; padding: 0; margin: 0;"}
  end
  
  def trouble_text_hash
    {:style => "#{@font_def + @grey_text_def}text-align: right; font-size: #{@small_font_size};"}
  end
  
  def view_it_hash
    {:style => "#{@font_def}text-align: right; font-size: #{@medium_font_size}; padding-top: 2px;"}
  end
  
  def browser_view_hash
    {:style => "width: 100%; padding-right: 10px; padding-top: 58px;"}
  end
  
  def link
    "color: #{@bright_green}; font-weight: bold; text-decoration: none;"
  end
  
  def youre_invited_hash
    {:width => 450}
  end
  
  def youre_invited_hash
    {}
  end
  
  def youre_invited_text_hash
    {:style => "#{@font_def}font-size: 40px; color: #{@bright_green};"}
  end
  
  def get_ready_hash
    {:style => "#{@font_def + @grey_text_def} font-size: 18px; padding-bottom: 7px;"}
  end
  
  def top_call_hash
    {:style => "text-align: right; width: 100%"}
  end
  
  def just_borders_hash
    {:style => @side_borders_def + "background: #{@top_light_grey}; width: 100%;"}
  end
  
  def description_hash
    {:style => "#{@font_def + @grey_text_def}font-size: 20px; padding-top: 15px; line-height: 24px; width: 544px; padding-bottom: 29px;"}
  end
  
  def actual_body_tag
    "margin: 0;"
  end
  
  def image
    "display: inline-block; vertical-align: bottom;"
  end
  
  def li_hash
    {:style => "#{@font_def + @grey_text_def} font-size: 16px; line-height: 20px; vertical-align: top; padding-top: 3px; padding-left: 10px;"}
  end
  
  def three_ways_hash
    {:style => "#{@font_def} font-size: 16px; font-weight: bold; color: #{@bright_green}; padding-bottom: 13px;"}
  end
  
  def tag_line_hash
    {:style => "#{@font_def + @side_borders_def} font-size: 16px; font-weight: bold; color: #{@bright_green}; padding-bottom: 13px; background: #{@top_light_grey}; width: #{@inner_width}px; padding-top: 22px; padding-left: 27px; padding-right: 27px; padding-bottom: 10px;"}
  end
  
  def not_alone_hash
    {:style => "#{@font_def} font-size: 16px; font-weight: bold; color: #{@bright_green}; padding-bottom: 8px;"}
  end
  
  def connect_hash
    {:style => "#{@font_def + @grey_text_def} font-size: 16px; line-height: 20px; padding-bottom: 16px;"}
  end
  
  def image_right
    {:style => "text-align: right; width: 100%; padding-bottom: 26px;"}
  end
  
  def bullet_hash
    {:style => "vertical-align: top;"}
  end
  
  def footer
    "#{@font_def + @nearly_white_def} font-size: 12px; line-height: 23px; text-decoration: none; text-align: center;"
  end
  
  def footer_hash
    {:style => footer}
  end
end