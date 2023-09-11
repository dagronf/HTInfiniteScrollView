//
//  ViewController.swift
//  HTInfiniteDocument Demo
//
//  Created by Darren Ford on 11/9/2023.
//

import Cocoa
import HTInfiniteScrollView

class ViewController: NSViewController {
	@IBOutlet var infiniteScrollView: NSScrollView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		
		// Enable layer-backing for the view hierarchy, required by the tile views
		self.view.wantsLayer = true
		
		// The frame size needs to be larger than the sum of largest attached screen + recenter threshold.
		self.infiniteScrollView.documentView?.setFrameSize(NSSize(width: 16384, height: 16384))
		
		// Provide the illusion of an infinite scroll view by hiding all the scrollers.
		self.infiniteScrollView.hasVerticalScroller = false
		self.infiniteScrollView.hasHorizontalScroller = false
		
		// There's no need for elasticity.
		self.infiniteScrollView.verticalScrollElasticity = .none
		self.infiniteScrollView.horizontalScrollElasticity = .none

		// Force an initial recenter so user can scroll in all directions.
		let clipView = self.infiniteScrollView.contentView as! HTInfiniteClipView
		clipView.recenterClipView()
	}
	
	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}
}
