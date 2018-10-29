import React from "react";
import PropTypes from "prop-types";

import TileImageComponent from './components/TileImageComponent';
import TileQuizComponent from './components/TileQuizComponent';
import attachmentFileExtensions from './constants/attachmentFileExtensions';
import LoadingComponent from '../../shared/LoadingComponent';
import { htmlSanitizer } from '../../lib/helpers';

const copyTile = (copyTileAction, tile, e) => {
  e.target.innerText = "Copied";
  copyTileAction(tile);
};

const fullSizeTileLoadingContainer = (closeTile) => (
  <div className="modal_container">
    <div className="modal_header">
      <a onClick={closeTile} className="close-reveal-modal stickable"><i className="fa fa-times fa-2x"></i></a>
    </div>
    <div className="modal_content">
      <div className="viewer">
        <div id="tile_preview_section">
          <div className="large-centered columns clearfix tile_preview_block">
            <div className="tile_holder" style={{width: '100%'}}>
            <div className="tile_full_image loading"></div>
              <div className="tile_main" style={{marginTop: '20%', marginBottom: '25%'}}>
                <LoadingComponent />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
);

const directionalButtons = (nextTile, prevTile) => (
  <div>
    <a onClick={prevTile} id="prev_tile" className="button_arrow prev_tile explore_next_prev" style={{display: 'block', left: '360px'}}></a>
    <a onClick={nextTile} id="next_tile" className="button_arrow next_tile explore_next_prev" style={{display: 'block', left: '1040px'}}></a>
  </div>
);

const tileOptsBar = opts => (
  <div>
    {(opts.tileOrigin === 'explore' && !(opts.userData.isGuestUser || opts.userData.isEndUser)) &&
      <ul className="tile_preview_menu explore_menu">
        <li className="preview_menu_item">
          <a className="copy_to_board" onClick={(e) => copyTile(opts.tileActions.copyTile, opts.tile, e)}>
            <i className="fa fa-copy fa-1x"></i>
            <span className="header_text">Copy to Board</span>
          </a>
        </li>
      </ul>
    }
  </div>
);

const tileTextsContainer = (headline, supportingContent) => (
  <div className="tile_texts_container">
    <div className="tile_headline content_sections">{headline}</div>
    <div className="tile_supporting_content content_sections">
      <p dangerouslySetInnerHTML={htmlSanitizer(supportingContent)} />
    </div>
  </div>
);

const tileAttachments = attachments => (
  <div className="attachments">
    <div className="attachment-list">
      {Object.keys(attachments).map(attachment => (
        <div className="tile-attachment" key={attachment.replace(/ /g,"_")}>
          <input type="hidden" name="tile[attachments][]" id={attachment.replace(/ /g,"_")} value={attachments[attachment]} />
          <i className="fa fa-times-circle attachment-delete" style={{display: 'none'}} />
          <a className="attachment-link" href={attachments[attachment]} target="_blank" rel="noopener noreferrer">
            <div className="tile-attachment-inner">
              <i className={`fa ${attachmentFileExtensions(attachment)} icon-tile-attachment`}></i>
              <div className="attachment-filename">
                {attachment}
              </div>
            </div>
          </a>
        </div>
      ))}
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
      fullSizeTileLoadingContainer(props.closeTile) :
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

              <div className="tile_holder" style={{width: '100%'}}>
                <TileImageComponent {...props} />

                <div className="tile_main">
                  {tileTextsContainer(props.tile.headline, props.tile.supportingContent)}
                  {props.tile.attachments && tileAttachments(props.tile.attachments)}
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

FullSizeTileComponent.propTypes = {
  tileOrigin: PropTypes.string,
  userData: PropTypes.shape({
    isGuestUser: PropTypes.bool,
    isEndUser: PropTypes.bool,
  }),
  tileActions: PropTypes.shape({
    copyTile: PropTypes.func,
  }),
  tile: PropTypes.shape({
    headline: PropTypes.string,
    supportingContent: PropTypes.string,
    attachments: PropTypes.object,
  }),
  loading: PropTypes.bool,
  closeTile: PropTypes.func,
  nextTile: PropTypes.func,
  prevTile: PropTypes.func,
};

export default FullSizeTileComponent;
