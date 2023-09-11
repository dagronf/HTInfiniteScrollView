//
//  HTInfiniteDocumentView.swift
//  HTInfiniteDocument Demo
//
//  Created by Darren Ford on 11/9/2023.
//

import Cocoa
import HTInfiniteScrollView

class HTInfiniteDocumentView: NSView {

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		// Drawing code here.
	}


	override func resizeSubviews(withOldSize oldSize: NSSize) {
		self.layoutDocumentView()
	}

	private var tileMap: [HTTileKey: NSView] = [:]
}

struct HTTileKey: Hashable {
	let x: Int
	let y: Int
}

// `HTInfiniteClipViewContent` implementation

extension HTInfiniteDocumentView: HTInfiniteClipViewContent {
	func layoutDocumentView() {
		let tileSize = CGSize(width: 250.0, height: 250.0)
		let visibleRect = self.visibleRect

		// min = inclusive; max = exclusive; i.e., [min, max)
		let xMinIndex = Int(floor(visibleRect.minX / tileSize.width))
		let xMaxIndex = Int(ceil(visibleRect.maxX / tileSize.width))

		let yMinIndex = Int(floor(visibleRect.minY / tileSize.height))
		let yMaxIndex = Int(ceil(visibleRect.maxY / tileSize.height))

		for x in (xMinIndex ..< xMaxIndex) {
			for y in (yMinIndex ..< yMaxIndex) {
				if abs(x + y) % 2 != 0 {
					// skip every other tile and alternate between rows
					continue;
				}

				let tileKey = HTTileKey(x: x, y: y)
				if self.tileMap[tileKey] == nil {
					let tileFrame = CGRect(
						origin: CGPoint(x: CGFloat(x) * tileSize.width, y: CGFloat(y) * tileSize.height),
						size: tileSize
					)
					let viewFrame = tileFrame.insetBy(dx: 20, dy: 20)
					let tileView = HTContentTileView(frame: viewFrame)
					tileView.title = "(\(x),\(y))"
					tileView.backgroundColor = (x % 2 == 0) ? .black : .blue
					self.addSubview(tileView)
					self.tileMap[tileKey] = tileView
				}
			}
		}

		// remove offscreen views
		self.tileMap.keys.forEach { tileKey in
			if !(xMinIndex <= tileKey.x && tileKey.x < xMaxIndex && yMinIndex <= tileKey.y && tileKey.y < yMaxIndex) {
				let tileView = self.tileMap[tileKey]
				self.tileMap.removeValue(forKey: tileKey)
				tileView?.removeFromSuperview()
			}
		}
	}
}
