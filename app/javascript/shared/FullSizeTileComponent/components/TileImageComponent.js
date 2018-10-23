import React from 'react';

const TileImageComponent = props => (
  <div className={props.tileOrigin === 'complete' ? 'complete' : 'not_completed'}>
    {
      props.tile.embedVideo &&
      <div className="video_section" style={{display: 'block'}}>
        {props.tile.embedVideo}
      </div>
    }

    {
      !props.tile.embedVideo &&
      <div className="image_section">
        <div className="tile_full_image {props.loading ? 'loading' : ''}">
          <img src={props.tile.imagePath} id="tile_img_preview" className="tile_image" alt={props.tile.headline} />
          <div className="shadow_overlay non-landing"></div>
          <div className="image_credit">
            {props.tile.imageCredit &&
              <div className="image_credit_view">
                <a href={props.tile.imageCredit} target="_blank">{props.tile.imageCredit}</a>
              </div>
            }
          </div>
        </div>
      </div>
    }
    <div id="tileGrayOverlay" style={{display: 'none'}}></div>
  </div>
);

export default TileImageComponent;
