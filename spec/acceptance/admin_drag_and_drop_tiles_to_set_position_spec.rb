require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

# Documentation for the simulateDragSortable script is at 
# https://github.com/mattheworiordan/jquery.simulate.drag-sortable.js

feature "Admin drags and drops tiles into position" do
  before(:each) do
    Demo.find_each { |f| f.destroy }
    @fun = FactoryGirl.create(:demo, name: 'Frickin FUN')
    @tile_1 = FactoryGirl.create(:tile, demo: @fun, name: 'Tile 1')
    @tile_2 = FactoryGirl.create(:tile, demo: @fun, name: 'Tile 2')
    @tile_3 = FactoryGirl.create(:tile, demo: @fun, name: 'Tile 3')
    @tile_4 = FactoryGirl.create(:tile, demo: @fun, name: 'Tile 4')
    signin_as_admin
    @tile_1.position.should == 1
    @tile_2.position.should == 2
    @tile_3.position.should == 3
    @tile_4.position.should == 4
  end

  it "should update the position", js: true do
    visit admin_demo_tiles_path(@fun)
    # Drag tile 1 down two places
    distance = 2
    script = "$('#tile_#{@tile_1.id}').simulateDragSortable({ move: #{distance}});"
    page.execute_script(script)
    wait_until { @tile_1.reload.position != 1}
    [@tile_1, @tile_2, @tile_3, @tile_4].each { |tile| tile.reload }
    @tile_2.position.should == 1
    @tile_3.position.should == 2
    @tile_1.position.should == 3
    @tile_4.position.should == 4
  end
end
