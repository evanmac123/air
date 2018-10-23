import React from "react";
import PropTypes from "prop-types";

import TileImageComponent from './components/TileImageComponent';
import TileQuizComponent from './components/TileQuizComponent';
import { htmlSanitizer } from '../../lib/helpers';

const directionalButtons = (nextTile, prevTile) => (
  <div>
    <a onClick={prevTile} id="prev_tile" className="button_arrow prev_tile explore_next_prev" style={{display: 'block', left: '360px'}}></a>
    <a onClick={nextTile} id="next_tile" className="button_arrow next_tile explore_next_prev" style={{display: 'block', left: '1040px'}}></a>
  </div>
);

const tileOptsBar = props => (
  <div>
    {(props.tileOrigin === 'explore' && !(props.userData.isGuestUser || props.userData.isEndUser)) &&
      <ul className="tile_preview_menu explore_menu">
        <li className="preview_menu_item">
          <a className="copy_to_board" onClick={() => props.tileActions.copyTile(props.tile)}>
            <i className="fa fa-copy fa-1x"></i>
            <span className="header_text">Copy to Board</span>
          </a>
        </li>
      </ul>
    }
  </div>
);

const tileMain = (headline, supportingContent) => (
  <div className="tile_texts_container">
    <div className="tile_headline content_sections">{headline}</div>
    <div className="tile_supporting_content content_sections">
      <p dangerouslySetInnerHTML={htmlSanitizer(supportingContent)} />
    </div>
  </div>
);

const FullSizeTileComponent = props => (
  <div className="reveal-modal standard_modal small tile_previews explore-tile_previews tile_previews-show explore-tile_previews-show bg-user-side"
    style={{
      display: 'block',
      opacity: '1',
      visibility: 'visible',
      top: '0px',
    }}
  >
  {
    props.loading ?
      <h1> LOADING!!! </h1> :
      <div className="modal_container">
        <div className="modal_header">
          <a onClick={props.closeTile} className="close-reveal-modal stickable"><i className="fa fa-times fa-2x"></i></a>
        </div>
        <div className="modal_content">
          <div className="viewer">
            {directionalButtons(props.nextTile, props.prevTile)}

            <div id="tile_preview_section">
              {tileOptsBar(props)}

            <div className="large-centered columns clearfix tile_preview_block">

              <div className="tile_holder">
                <TileImageComponent {...props} />

                <div className="tile_main">
                  {tileMain(props.tile.headline, props.tile.supportingContent)}
                </div>

                <TileQuizComponent {...props} />
              </div>

            </div>
          </div>
        </div>
      </div>
    </div>
  }
  </div>
);

export default FullSizeTileComponent;


//   <div className="tile-social-share-component">
//   <div className="share_bar center text-center">
//     <div className="social-share jssocials" data-twitter-hashtags="[&quot;airbo&quot;]" data-tile-path="https://airbo.com/explore/tile/42099" data-share-text="Why are annual physicals important?"><div className="jssocials-shares"></div></div>
//     <br>
//     <div className="share_title">Share Link</div>
//     <div className="share_link_block copy-to-clipboard-input-group">
//       <input type="text" name="share_tile_link" id="share_link" value="https://airbo.com/explore/tile/42099" className="share-link">
//       <div className="copy-to-clipboard-button js-copy-to-clipboard-btn" data-tooltip="publicBoard" title="Click to Copy" data-clipboard-target="#share_link"></div>
//     </div>
//   </div>
// </div>
//
//
//
//    <div id="tileGrayOverlay" style=""> </div>
//
//  </div>
//
// </div>
//
//
//     </div>
//   </div>
//
// </div>
//
// <div className="bars">
//     <div className="center bar_for_preview align_left offset_top">
//       <div className="creator">
//     <img className="company_logo default_logo" src="https://d21lri3dx8dmnu.cloudfront.net/assets/logo-38918da1c171d7b0fb7106d5967552b0.png" alt="Logo">
//     <span className="creator_name">
//         Tile by Diana at Airbo Boards
//     </span>
// </div>
//
//     </div>
// </div>
// </div>
//   </div>

// <div>
// {props.tileOrigin === 'explore' &&
// <h1 onClick={props.closeTile}>X</h1>
// }
// <h2>{props.tile.headline}</h2>
// <ul>
// <li>supportingContent: {props.tile.supportingContent}</li>
// <li>Points: {props.tile.points}</li>
// </ul>
// <h3 onClick={props.nextTile}>Next</h3>
// <h3 onClick={props.prevTile}>Prev</h3>
// </div>
