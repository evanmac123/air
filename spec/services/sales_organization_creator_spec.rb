require 'spec_helper'

describe SalesOrganizationCreator do
  let(:sa) { FactoryBot.create(:site_admin) }

  def org_params
    {"name"=>"Test Org",
     "is_hrm"=>"0",
     "users_attributes"=>
      {"0"=>
        {
          "name"=>"Testorg User", "email"=>"testorguser@example.com", "password"=>"password", "is_client_admin"=>"true"
        }
      },
     "boards_attributes"=>
      {
        "0"=>{"name"=>""}
      }
    }
  end

  describe "#new" do
    describe "no copy board" do
      it "instantiates with correct attrs_readers" do
        service = SalesOrganizationCreator.new(sa, nil, org_params)

        expect(service.creator).to eq(sa)
        expect(service.organization.class).to eq(Organization)
        expect(service.board.class).to eq(Demo)
        expect(service.user.class).to eq(User)
      end
    end

    describe "with copy board" do
      it "instantiates with a demo to copy" do
        demo = FactoryBot.create(:demo)
        service = SalesOrganizationCreator.new(sa, demo, org_params)

        expect(service.copy_board).to eq(demo)
      end
    end
  end

  describe "#valid?" do
    it "returns true if org persisted" do
      service = SalesOrganizationCreator.new(sa, nil, org_params).create!

      expect(service.valid?).to be true
    end

    it "returns false if org is not persisted" do
      service = SalesOrganizationCreator.new(sa, nil, org_params)

      expect(service.valid?).to be false
    end
  end

  describe "#create!" do

    it "persists the org" do
      service = SalesOrganizationCreator.new(sa, nil, org_params).create!

      expect(service.organization.persisted?).to be true
    end

    it "persists the client admin" do
      service = SalesOrganizationCreator.new(sa, nil, org_params).create!

      expect(service.user.persisted?).to be true
    end

    it "persists the board" do
      service = SalesOrganizationCreator.new(sa, nil, org_params).create!

      expect(service.board.persisted?).to be true
    end

    it "persists the client admin's board membership" do
      service = SalesOrganizationCreator.new(sa, nil, org_params).create!

      expect(service.user.board_memberships.first.persisted?).to be true
    end

    describe "#update_board_name_and_email" do
      it "updates board name to org name if no board name" do
        service = SalesOrganizationCreator.new(sa, nil, org_params).create!

        expect(service.board.name).to eq(org_params["name"])
        expect(service.board.email).to eq(org_params["name"].parameterize + "@ourairbo.com")
      end

      it "updates board name to given board name" do
        params = org_params
        params["boards_attributes"]["0"]["name"] = "Board Name"
        service = SalesOrganizationCreator.new(sa, nil, params).create!

        expect(service.board.name).to eq("Board Name")
      end
    end

    describe "#set_sales_defaults" do
      it "updates guest_user_conversion_modal" do
        service = SalesOrganizationCreator.new(sa, nil, org_params).create!

        expect(service.board.guest_user_conversion_modal).to eq(false)
      end
    end

    describe "#link_board_and_user" do
      it "links the user to the board via a board_membership" do
        service = SalesOrganizationCreator.new(sa, nil, org_params).create!

        user_bms = service.user.board_memberships

        expect(user_bms.count).to eq(1)
        expect(user_bms.first.demo).to eq(service.board)
      end
    end

    describe "#setup_sales_org" do
      it "moves the creator to the created board" do
        service = SalesOrganizationCreator.new(sa, nil, org_params).create!

        expect(service.creator.demo).to eq(service.board)
      end

      it "adds a sales role to the organization scoped tot he creator" do
        service = SalesOrganizationCreator.new(sa, nil, org_params).create!

        sales_role = service.creator.roles.first

        expect(sales_role.name).to eq("sales")
        expect(sales_role.resource_id).to eq(service.organization.id)
      end

      it "doesn not copy tiles if copy_board is nil" do
        service = SalesOrganizationCreator.new(sa, nil, org_params).create!

        expect(service.board.tiles.present?).to be false
      end

      it "copies the tiles of the provided copy board" do
        copy_board = FactoryBot.create(:demo)
        tiles = FactoryBot.create_list(:tile, 3, demo: copy_board)

        service = SalesOrganizationCreator.new(sa, copy_board.id.to_s, org_params).create!

        expect(service.board.tiles.count).to eq(tiles.count)
        expect(service.board.tiles.pluck(:headline).sort).to eq(tiles.map(&:headline).sort)
      end
    end
  end
end
