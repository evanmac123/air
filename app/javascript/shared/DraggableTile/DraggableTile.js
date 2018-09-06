import React, { Component } from 'react';
import PropTypes from "prop-types";
import {
  DragSource,
	DropTarget,
} from 'react-dnd';
import { getEmptyImage } from 'react-dnd-html5-backend';
import flow from 'lodash.flow';

import ItemTypes from './ItemTypes';
import TileComponent from '../TileComponent';

const tileSource = {
	beginDrag(props) {
    const tiles = document.getElementsByClassName('tile-wrapper');
    for (let i = 0; i < tiles.length; i++) {
      tiles[i].setAttribute('style', 'pointer-events:none;');
    }
		return {
      id: props.id,
      thumbnail: props.thumbnail,
      headline: props.headline,
      caledarIcon: props.caledarIcon,
      date: props.date,
      copyButtonDisplay: props.copyButtonDisplay,
      calendarClass: props.calendarClass,
      campaignColor: props.campaignColor,
      index: props.index,
    };
	},

  canDrag(props) {
    return props.activeFilters.sortType === null || props.activeFilters.sortType.value !== 'date-sort';
  },
};

const tileTarget = {
	hover(props, monitor, component) {
		if (!component) { return; }
		const dragIndex = monitor.getItem().index;
		const hoverIndex = props.index;
		if (dragIndex === hoverIndex) { return; }
		props.moveTile(dragIndex, hoverIndex);
		monitor.getItem().index = hoverIndex; // eslint-disable-line
	},
  drop(props) {
    const tiles = document.getElementsByClassName('tile-wrapper');
    for (let i = 0; i < tiles.length; i++) {
      tiles[i].removeAttribute('style');
    }
    props.sortTile(props.index);
  },
};

function getStyles(isDragging) {
	return {
		opacity: isDragging ? 0 : 1,
	};
}

function dropCollect(connect) {
	return {connectDropTarget: connect.dropTarget()};
}

function dragCollect(connect, monitor) {
  return {
    connectDragSource: connect.dragSource(),
  	connectDragPreview: connect.dragPreview(),
  	isDragging: monitor.isDragging(),
  };
}

class DraggableTile extends Component {
	componentDidMount() {
		const { connectDragPreview } = this.props;
		if (connectDragPreview) {
			// Use empty image as a drag preview so browsers don't draw it
			// and we can draw whatever we want on the custom drag layer instead.
			connectDragPreview(getEmptyImage(), {
				// IE fallback: specify that we'd rather screenshot the node
				// when it already knows it's being dragged so we can hide it with CSS.
				captureDraggingState: true,
			});
		}
	}

	render() {
    const {
      isDragging,
      connectDropTarget,
      connectDragSource,
      id,
      thumbnail,
      headline,
      caledarIcon,
      date,
      copyButtonDisplay,
      calendarClass,
      campaignColor,
      tileContainerClass,
      tileThumblinkClass,
      shadowOverlayButtons,
      popdownMenu,
      loading,
      tileThumblinkOnClick,
      tileStats,
      ignored,
    } = this.props;

		return (
      connectDropTarget &&
			connectDragSource &&
			connectDragSource(
        connectDropTarget(
          <div style={getStyles(isDragging)} className={`tile_container ${tileContainerClass}`}>
            <TileComponent
              id={id}
              headline={headline}
              thumbnail={thumbnail}
              caledarIcon={caledarIcon}
              date={date}
              copyButtonDisplay={copyButtonDisplay}
              calendarClass={calendarClass}
              campaignColor={campaignColor}
              tileContainerClass={tileContainerClass}
              tileThumblinkClass={tileThumblinkClass}
              shadowOverlayButtons={shadowOverlayButtons}
              popdownMenu={popdownMenu}
              loading={loading}
              tileThumblinkOnClick={tileThumblinkOnClick}
              draggable={true}
              tileStats={tileStats}
              ignored={ignored}
            />
          </div>
        )
			)
		);
	}
}

DraggableTile.propTypes = {
  connectDragPreview: PropTypes.func.isRequired,
  isDragging: PropTypes.bool.isRequired,
  connectDropTarget: PropTypes.func.isRequired,
  connectDragSource: PropTypes.func.isRequired,
  id: PropTypes.number,
  thumbnail: PropTypes.string,
  headline: PropTypes.string,
  caledarIcon: PropTypes.string,
  date: PropTypes.string,
  copyButtonDisplay: PropTypes.bool,
  calendarClass: PropTypes.string,
  campaignColor: PropTypes.string,
  tileContainerClass: PropTypes.string,
  tileThumblinkClass: PropTypes.string,
  shadowOverlayButtons: PropTypes.array,
  popdownMenu: PropTypes.element,
  loading: PropTypes.bool,
  ignored: PropTypes.bool,
  tileThumblinkOnClick: PropTypes.func,
  tileStats: PropTypes.arrayOf(PropTypes.element),
};

export default flow(
  DragSource(ItemTypes.TILE, tileSource, dragCollect),
  DropTarget(ItemTypes.TILE, tileTarget, dropCollect),
)(DraggableTile);
