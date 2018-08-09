import React from "react";
import PropTypes from "prop-types";

const TileComponent = props => (
  <div className="tile_container plan" data-tile-container-id={props.id}>
    <div className="tile_thumbnail" id={`single-tile-${props.id}`}>
      <div className="tile-wrapper">
        <a href={props.tileShowPath} className='tile_thumb_link tile_thumb_link_client_admin' data-tile-id={props.id}>
          <div className="tile_thumbnail_image">
            <img src={props.thumbnail} />
          </div>
          {
            props.date &&
            <div className="activation_dates">
              <span className='tile-active-time'>
                <i className={`fa ${props.caledarIcon}`}></i>
                {props.date}
              </span>
            </div>
          }
          <div className="headline">
            <div className="text">
              {props.headline}
            </div>
          </div>
          <div className="shadow_overlay">
          {props.clientAdminButtons &&
            <ul className="tile_buttons">
            {props.changeStatusButton &&
              <li className={props.changeStatusClass}>
                <a className="button update_status" data-action="draft" data-status="draft" data-tile-id={props.id} href={props.changeStatusPath}>
                  {props.changeStatusButton}
                </a>
              </li>
            }
            {props.destroyTileButton &&
              <li className="destroy pill right">
                <a className="delete_tile" data-action="delete" data-tile-id={props.id}>
                  <i className="fa fa-trash"></i>
                </a>
              </li>
            }
              <li className="pill more right">
                <span className="dot"></span>
                <span className="dot"></span>
                <span className="dot"></span>
              </li>
              <li className="edit_button pill right">
                <a className="edit" data-action="edit" data-tile-id={props.id} data-status="plan" href="">
                  <i className="fa fa-pencil"></i>
                </a>
              </li>
            </ul>
          }
          </div>
          <div className="tile_overlay"></div>
        </a>

        {(props.copyButtonDisplay && !(props.user.isGuestUser || props.user.isEndUser)) &&
          <ul className="tile_buttons">
            <li className="explore_copy_button">
              <a
                onClick={() => props.copyTile({id: props.id, copyPath: props.copyPath})}
                className="button outlined explore_copy_link"
                id={props.id}
                data-tile-id={props.id}
                data-section="Explore"
              >
                <span className="explore_thumbnail_copy_text">
                  Copy
                </span>
              </a>
            </li>
          </ul>
        }
      </div>
    </div>
  </div>
);

TileComponent.propTypes = {
  id: PropTypes.number.isRequired,
  thumbnail: PropTypes.string.isRequired,
  headline: PropTypes.string.isRequired,
  tileShowPath: PropTypes.string.isRequired,
  copyPath: PropTypes.string,
  copyTile: PropTypes.func,
  user: PropTypes.shape({
    isGuestUser: PropTypes.bool,
    isEndUser: PropTypes.bool,
  }),
  caledarIcon: PropTypes.string,
  date: PropTypes.string,
  copyButtonDisplay: PropTypes.bool,
};

export default TileComponent;
