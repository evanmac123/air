import React from "react";
import PropTypes from "prop-types";
import LoadingComponent from "../LoadingComponent";
import RibbonTagComponent from "../RibbonTagComponent";

const TileComponent = props => (
  <div className={props.draggable ? '' : `tile_container ${props.tileContainerClass}`}
       data-tile-container-id={props.id}
       disabled={props.loading}
       style={props.loading ? {pointerEvents: 'none'} : {}}
  >
    <div className={`tile_thumbnail ${props.tileThumbnailClass}`} id={`single-tile-${props.id}`}>
      <div className="tile-wrapper">
        <a href={props.tileShowPath} className={props.tileThumblinkClass} data-tile-id={props.id} onClick={props.tileThumblinkOnClick}>
          <div className="tile_thumbnail_image" style={props.ignored ? {opacity: '0.5'} : {}}>
            <img src={props.thumbnail} />
            {props.ribbonTagName &&
              <RibbonTagComponent
                ribbonTagName={props.ribbonTagName}
                ribbonTagColor={props.ribbonTagColor}
                height="28"
              />
            }
          </div>
          {
            props.date &&
            <div className={`activation_dates ${props.calendarClass}`}>
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
          {
            props.loading &&
            <div className="loading_overlay" style={{
              display: 'block',
              width: '100%',
              height: '100%',
              position: 'absolute',
              bottom: '0',
              left: '0',
              background: 'rgba(255, 255, 255, 0.92)',
              zIndex: '1',
            }}>
              <LoadingComponent />
            </div>
          }
          <div style={{height: '3px', backgroundColor: (props.campaignColor || '#fff')}}>
          </div>
          <div className="shadow_overlay">
          {props.shadowOverlayButtons &&
            <ul className="tile_buttons">
              {props.shadowOverlayButtons}
            </ul>
          }
          </div>
          {props.popdownMenu &&
            <div className="popdown-menu">
              {props.popdownMenu}
            </div>
          }
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
    {props.tileStats &&
      <div className="tile_stats">
        { props.tileStats }
      </div>
    }
  </div>
);

TileComponent.propTypes = {
  id: PropTypes.number.isRequired,
  thumbnail: PropTypes.string.isRequired,
  headline: PropTypes.string.isRequired,
  tileShowPath: PropTypes.string,
  copyPath: PropTypes.string,
  copyTile: PropTypes.func,
  user: PropTypes.shape({
    isGuestUser: PropTypes.bool,
    isEndUser: PropTypes.bool,
  }),
  caledarIcon: PropTypes.string,
  date: PropTypes.string,
  copyButtonDisplay: PropTypes.bool,
  tileContainerClass: PropTypes.string,
  tileThumbnailClass: PropTypes.string,
  tileThumblinkClass: PropTypes.string,
  shadowOverlayButtons: PropTypes.array,
  popdownMenu: PropTypes.element,
  tileThumblinkOnClick: PropTypes.func,
  loading: PropTypes.bool,
  ignored: PropTypes.bool,
  calendarClass: PropTypes.string,
  campaignColor: PropTypes.string,
  draggable: PropTypes.bool,
  tileStats: PropTypes.arrayOf(PropTypes.element),
  ribbonTagName: PropTypes.string,
  ribbonTagColor: PropTypes.string,
};

export default TileComponent;
