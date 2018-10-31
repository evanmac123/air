import React from 'react';
import { connect } from "react-redux";

import { getSanitizedState } from "../../lib/redux/selectors";

class ProgressBarComponent extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div className="user_container">
      {
        !this.props.organization.name ? <h1>Loading</h1> :
          <div id="user_progress">

            <span className="WHERE_RAFFLE_GOES!!!" style={{display: 'none'}} />

            <div id="total_section">
              <div className="progress_header" id="total_header">
                {this.props.organization.pointsWording}
              </div>
              <div id="total_points">
                {this.props.userData.points}
              </div>
            </div>
            <div id="tile_section">
              <div className="progress_header" id="tile_header">
                {this.props.organization.tilesWording}
              </div>
              <div id="tile_progress_bar">

                  <div id="all_tiles">
                    ??
                  </div>

                <div id="completed_tiles">
                  <div id="complete_info">
                    <span className="fa fa-check"></span>
                    <span id="completed_tiles_num">
                      0
                    </span>
                  </div>
                  <div id="congrat_header">
                    <i className="fa fa-flag-checkered"></i>
                    <div id="congrat_text">
                      Finished!
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
      }
      </div>
    );
  }
}

export default connect(
  getSanitizedState,
  {}
)(ProgressBarComponent);

// <%=content_tag :div,  class: "user_container", data:{config:presenter.config} do%>
//   <div id="user_progress">
//     <% if raffle %>
//       <%= render partial: "shared/tiles/raffle_progress", locals: {raffle: raffle}  %>
//     <% end %>
//     <div id="total_section">
//       <div className="progress_header" id="total_header">
//         <%= org_points_wording.capitalize %>
//       </div>
//       <div id="total_points">
//         <%= presenter.points %>
//       </div>
//     </div>
//     <div id="tile_section">
//       <div className="progress_header" id="tile_header">
//         Tiles
//       </div>
//       <div id="tile_progress_bar">
//         <% if presenter.some_tiles_undone %>
//           <div id="all_tiles">
//             <%= presenter.available_tile_count %>
//           </div>
//         <% end %>
//         <div id="completed_tiles">
//           <div id="complete_info">
//             <span className="fa fa-check"></span>
//             <span id="completed_tiles_num">
//               <%= presenter.completed_tile_count %>
//             </span>
//           </div>
//           <div id="congrat_header">
//             <icon className="fa fa-flag-checkered"></icon>
//             <div id="congrat_text">
//               Finished!
//             </div>
//           </div>
//         </div>
//       </div>
//     </div>
//   </div>
// <%end%>
//
// <% if raffle && current_user.can_see_raffle_modal? %>
//   <%= render partial: "client_admin/prizes/prize_modal", locals: { raffle: raffle } %>
// <% end %>
