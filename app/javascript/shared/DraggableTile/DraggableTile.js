import React, { Component } from 'react';
import { DragSource, ConnectDragSource, ConnectDragPreview } from 'react-dnd';
import { getEmptyImage } from 'react-dnd-html5-backend';
import ItemTypes from './ItemTypes';
import TileComponent from '../TileComponent';

const tileSource = {
	beginDrag(props) {
    const {
      id,
      thumbnail,
      headline,
      caledarIcon,
      date,
      copyButtonDisplay,
      calendarClass,
      campaignColor,
    } = props
		return {
      id,
      thumbnail,
      headline,
      caledarIcon,
      date,
      copyButtonDisplay,
      calendarClass,
      campaignColor,
    }
	},
}

function getStyles(props) {
	const { left, top, isDragging } = props
	const transform = `translate3d(${left}px, ${top}px, 0)`

	return {
		position: 'absolute',
		transform,
		WebkitTransform: transform,
		// IE fallback: hide the real node using CSS when dragging
		// because IE will ignore our custom "empty image" drag preview.
		opacity: isDragging ? 0 : 1,
		height: isDragging ? 0 : '',
	}
}

function collect(connect, monitor) {
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
			connectDragSource &&
			connectDragSource(
        <div>
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
          />
        </div>
			)
		)
	}
}

export default DragSource(ItemTypes.TILE, tileSource, collect)(DraggableTile);
