import React, { Component } from 'react';
import { findDOMNode } from 'react-dom';
import {
  DragSource,
  ConnectDragSource,
  ConnectDragPreview,
	DropTarget,
	ConnectDropTarget,
	DropTargetMonitor,
	DropTargetConnector,
	DragSourceConnector,
	DragSourceMonitor,
} from 'react-dnd';
import { getEmptyImage } from 'react-dnd-html5-backend';
import { XYCoord } from 'dnd-core';
import flow from 'lodash/flow';

import ItemTypes from './ItemTypes';
import TileComponent from '../TileComponent';

const tileSource = {
	beginDrag(props) {
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
    }
	},
};

const tileTarget = {
	hover(props, monitor, component) {
		if (!component) {
			return null
		}
		const dragIndex = monitor.getItem().index
		const hoverIndex = props.index
		if (dragIndex === hoverIndex) {
			return
		}
		const hoverBoundingRect = findDOMNode(component).getBoundingClientRect();
		const hoverMiddleY = (hoverBoundingRect.right - hoverBoundingRect.left) / 2;
		const clientOffset = monitor.getClientOffset();
		const hoverClientY = clientOffset.y - hoverBoundingRect.top;

		props.moveTile(dragIndex, hoverIndex);
		monitor.getItem().index = hoverIndex;
console.log(dragIndex, hoverIndex);
	},
};

function getStyles(isDragging) {
	return {
		opacity: isDragging ? 0 : 1,
		// height: isDragging ? 0 : '',
	}
}

function dropCollect(connect) {
	return {connectDropTarget: connect.dropTarget()};
}

function dragCollect(connect, monitor) {
  return {
    connectDragSource: connect.dragSource(),
  	connectDragPreview: connect.dragPreview(),
  	isDragging: monitor.isDragging(),
  }
}

class DraggableTile extends Component {
	componentDidMount() {
		const { connectDragPreview } = this.props
		if (connectDragPreview) {
			// Use empty image as a drag preview so browsers don't draw it
			// and we can draw whatever we want on the custom drag layer instead.
			connectDragPreview(getEmptyImage(), {
				// IE fallback: specify that we'd rather screenshot the node
				// when it already knows it's being dragged so we can hide it with CSS.
				captureDraggingState: true,
			})
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
    } = this.props

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
            />
          </div>
        )
			)
		)
	}
}

export default flow(
  DragSource(ItemTypes.TILE, tileSource, dragCollect),
  DropTarget(ItemTypes.TILE, tileTarget, dropCollect),
)(DraggableTile)
