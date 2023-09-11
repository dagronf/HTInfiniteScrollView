//
//  HTContentTileView.swift
//  HTInfiniteDocument Demo
//
//  Created by Darren Ford on 11/9/2023.
//

import AppKit
import Foundation

class HTContentTileView: NSView {
	private let titleLayer = DFCenteringTextLayer()
	var title: String = "" {
		didSet {
			self.needsDisplay = true
		}
	}

	var backgroundColor: NSColor = .white {
		willSet {
			if newValue != self.backgroundColor {
				self.needsDisplay = true
			}
		}
	}

	override var wantsUpdateLayer: Bool { true }
	override func updateLayer() {
		self.layer?.backgroundColor = self.backgroundColor.cgColor
		self.titleLayer.frame = self.bounds
		self.titleLayer.string = self.title
	}

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.wantsLayer = true
		self.build()
		self.layer?.addSublayer(self.titleLayer)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("Not implemented")
	}

	private func build() {
		self.titleLayer.contentsScale = 2
		self.titleLayer.font = NSFont.systemFont(ofSize: 10)
		self.titleLayer.fontSize = 16
		self.titleLayer.zPosition = 20
		self.titleLayer.alignmentMode = .center
		self.titleLayer.foregroundColor = NSColor.white.cgColor
	}
}

/// Centering text layer
private class DFCenteringTextLayer: CATextLayer {
	override open func draw(in ctx: CGContext) {
		let yDiff: CGFloat
		let fontSize: CGFloat
		let height = self.bounds.height

		if let attributedString = self.string as? NSAttributedString {
			fontSize = attributedString.size().height
			yDiff = (height - fontSize) / 2
		}
		else {
			fontSize = self.fontSize
			yDiff = ((height - fontSize) / 2) - (fontSize / 10)
		}

		ctx.saveGState()
		ctx.translateBy(x: 0.0, y: -yDiff)
		super.draw(in: ctx)
		ctx.restoreGState()
	}
}
