import React from "react";
import PropTypes from "prop-types";

import TileImageComponent from './components/TileImageComponent';
import TileQuizComponent from './components/TileQuizComponent';
import attachmentFileExtensions from './constants/attachmentFileExtensions';
import LoadingComponent from '../../shared/LoadingComponent';
import ProgressBarComponent from '../../shared/ProgressBarComponent';
import { htmlSanitizer } from '../../lib/helpers';

const copyTile = (copyTileAction, tile, e) => {
  e.target.innerText = "Copied";
  copyTileAction(tile);
};

const directionalButtons = (nextTile, prevTile) => (
  <div>
    <a onClick={prevTile} id="prev_tile" className="button_arrow prev_tile explore_next_prev" style={{display: 'block', left: '360px'}}></a>
    <a onClick={nextTile} id="next_tile" className="button_arrow next_tile explore_next_prev" style={{display: 'block', left: '1040px'}}></a>
  </div>
);

const fullSizeTileLoadingContainer = tileOrigin => (
  <div className="viewer">
  {tileOrigin === 'explore' && directionalButtons(() => {}, () => {})}
  {tileOrigin !== 'explore' && <a id="prev" className="react-dir"></a>}
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
    {tileOrigin !== 'explore' && <a id="next" className="react-dir"></a>}
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
      {Object.keys(attachments).map((attachment, key) => (
        <div className="tile-attachment" key={`${attachment.replace(/ /g,"_")}${key}`}>
          <input type="hidden" name="tile[attachments][]" id={attachment.replace(/ /g,"_")} value={attachments[attachment]} />
          <i className="fa fa-times-circle attachment-delete" style={{display: 'none'}} />
          <a className={`attachment-link ${key}`} href={attachments[attachment]} target="_blank" rel="noopener noreferrer">
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

const sanitizeClassList = classList => {
  const result = [];
  for (let i = 0; i < classList.length; i++) { result.push(classList[i]); }
  return result;
};

const parseClickTarget = target => {
  const sanitizedClassList = sanitizeClassList(target.classList);
  const attachmentClicked = (
    sanitizedClassList.indexOf('attachment-filename') > -1 ||
    sanitizedClassList.indexOf('icon-tile-attachment') > -1 ||
    sanitizedClassList.indexOf('tile-attachment-inner') > -1 ||
    sanitizedClassList.indexOf('attachment-link') > -1
  );
  if (attachmentClicked) {
    if (sanitizedClassList.indexOf('attachment-link') > -1) { return target; }
    if (sanitizedClassList.indexOf('tile-attachment-inner') > -1) { return target.parentElement; }
    if (sanitizedClassList.indexOf('attachment-filename') > -1 || sanitizedClassList.indexOf('icon-tile-attachment') > -1) {
      return target.parentElement.parentElement;
    }
  }
  return target;
};

const checkIfLinkClick = (e, tileId, trackLinkClick) => {
  e.preventDefault();
  const target = parseClickTarget(e.target);
  if (target.tagName === "A" && target.getAttribute("href")) {
    trackLinkClick(target, tileId);
  }
};

const wrapper = {
  className: {
    complete: "",
    incomplete: "",
    explore: "reveal-modal standard_modal small tile_previews explore-tile_previews tile_previews-show explore-tile_previews-show bg-user-side",
  },
  style: {
    complete: {},
    incomplete: {},
    explore: {
      display: 'block',
      opacity: '1',
      visibility: 'visible',
      top: '0px',
    },
  },
};

const FullSizeTileComponent = props => (
  <div className={wrapper.className[props.tileOrigin]} style={wrapper.style[props.tileOrigin]}>
    <div className={props.tileOrigin === 'explore' ? "modal_container" : ""}>
      {props.tileOrigin === 'explore' &&
        <div className="modal_header">
          <a onClick={props.closeTile} className="close-reveal-modal stickable"><i className="fa fa-times fa-2x"></i></a>
        </div>
      }
      {props.tileOrigin !== 'explore' && <div className="acts-index"><ProgressBarComponent /></div>}
      <div className={props.tileOrigin === 'explore' ? "modal_content" : "container row"}>
        {
          props.loading || !props.organization.name ?
            fullSizeTileLoadingContainer(props.tileOrigin) :
            <div className="viewer">
              {props.tileOrigin === 'explore' && directionalButtons(props.nextTile, props.prevTile)}
              {props.tileOrigin !== 'explore' && <a id="prev" onClick={props.prevTile} className="react-dir"></a>}
              <div id="tile_preview_section">
                {tileOptsBar(props)}

                <div className="large-centered columns clearfix tile_preview_block">
                  <div className="tile_holder" style={{width: '100%'}}>
                    <TileImageComponent {...props} />

                    <div className="tile_main" onClick={(e) => { checkIfLinkClick(e, props.tile.id, props.trackLinkClick); }}>
                      {tileTextsContainer(props.tile.headline, props.tile.supportingContent)}
                      {props.tile.attachments && tileAttachments(props.tile.attachments)}
                    </div>

                    <TileQuizComponent {...props} />
                  </div>
                </div>
              </div>
              {props.tileOrigin !== 'explore' && <a id="next" onClick={props.nextTile} className="react-dir"></a>}
            </div>
          }
      </div>
    </div>
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
    id: PropTypes.number,
    headline: PropTypes.string,
    supportingContent: PropTypes.string,
    attachments: PropTypes.object,
  }),
  loading: PropTypes.bool,
  closeTile: PropTypes.func,
  nextTile: PropTypes.func,
  prevTile: PropTypes.func,
  trackLinkClick: PropTypes.func,
  organization: PropTypes.object,
};

export default FullSizeTileComponent;
