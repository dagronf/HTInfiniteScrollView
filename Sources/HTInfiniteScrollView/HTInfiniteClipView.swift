//
//  HTInfiniteClipView.swift
//
//  Created by Milen Dzhumerov on 31/03/2015.
//  Copyright (c) 2015 Helftone. All rights reserved.
//
//  Converted to Swift 5.4 by Darren Ford on 11/9/2023
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import AppKit

@objc public protocol HTInfiniteClipViewContent {
	// This method will be called whenever the visible rect changes. This can be done synchronously
	// (e.g., on bounds change) or asynchronously (e.g., async dispatch) or any other way.
	//
	// Your document view must implement this method for infinite scrolling to work
	//
	// Note this function will be called for EACH visible rect change, so make sure that your
	// implementation is performant
	@objc func layoutDocumentView()
}

/// A infinitely scrollable clip view
@objc public class HTInfiniteClipView: NSClipView {
	/// Initializes and returns a newly allocated NSView object with a specified frame rectangle.
	override public init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	/// Initializes a view using from data in the specified coder object.
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	deinit {
		self.teardown()
	}

	// Private
	private var inRecenter = false
	private var recenterScheduled = false
}

// MARK: - Setup/teardown

extension HTInfiniteClipView {
	private func setup() {
		self.postsBoundsChangedNotifications = true

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(internal_viewGeometryChanged(_:)),
			name: NSView.boundsDidChangeNotification,
			object: self
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(internal_viewGeometryChanged(_:)),
			name: NSView.frameDidChangeNotification,
			object: self
		)
	}

	private func teardown() {
		NotificationCenter.default.removeObserver(self)
	}
}

// MARK: - Recenter

extension HTInfiniteClipView {
	@objc func internal_viewGeometryChanged(_ notification: Notification) {
		assert(Thread.isMainThread)

		if self.internal_clipRecenterOffset() != .zero {
			// We cannot perform recentering from within the notification (it's synchrounous) due to a bug
			// in NSScrollView ... *sigh*
			self.internal_scheduleRecenter()
		}

		if let docView = self.documentView as? HTInfiniteClipViewContent {
			docView.layoutDocumentView()
		}
	}

	/// Recenter the clip view
	public func recenterClipView() {
		//
		//      ┌────────────────────────────────────────────────┐
		//      │Document View                                   │
		//      │                                                │
		//      │                                                │
		//      │                                                │
		//      │                                                │
		//      │                                                │
		//      │                                                │
		//      │                                                │
		//      │                                                │
		//      │                                                │
		//      │    ┌────────────────┐                          │
		//      │    │                │                          │
		//      │◁──▷│   Clip View    │                          │
		//      │    │                │                          │
		//      │    └────────────────┘                          │
		//      │             △                                  │
		//      │             │                                  │
		//      │             ▽                                  │
		//      └────────────────────────────────────────────────┘
		//    (0,0)
		//
		//                  Recenter Offset: (200,100)
		//
		//                              │
		//                              │
		//                              │
		//                              │
		//                              ▼
		//
		//
		//      ┌────────────────────────────────────────────────┐
		//      │Document View                                   │
		//      │                                                │
		//      │                                                │
		//      │                                                │
		//      │                                                │
		//      │                                                │
		//      │               ┌────────────────┐               │
		//      │               │                │               │
		//      │◁─────────────▷│   Clip View    │               │
		//      │               │                │               │
		//      │               └────────────────┘               │
		//      │                        △                       │
		//      │                        │                       │
		//      │                        │                       │
		//      │          ●             │                       │
		//      │        (0,0)           │                       │
		//      │                        │                       │
		//      │                        ▽                       │
		//      └────────────────────────────────────────────────┘
		// (-200,-100)
		//
		// Created with [Monodraw](https://monodraw.helftone.com)

		assert(Thread.isMainThread)

		// If no document, return
		guard let docView = self.documentView else { return }

		// If no change to the clip center, finish
		let clipRecenterOffset = self.internal_clipRecenterOffset()
		guard clipRecenterOffset != .zero else {
			return
		}

		self.inRecenter = true
		defer { self.inRecenter = false }

		var recenterDocBounds = docView.bounds
		recenterDocBounds.origin.x -= clipRecenterOffset.x
		recenterDocBounds.origin.y -= clipRecenterOffset.y

		docView.setBoundsOrigin(recenterDocBounds.origin)

		let clipBounds = self.bounds
		var recenterClipOrigin = clipBounds.origin
		recenterClipOrigin.x += clipRecenterOffset.x
		recenterClipOrigin.y += clipRecenterOffset.y
		self.setBoundsOrigin(recenterClipOrigin)

//		#if DEBUG
//		Swift.print("Did recenter infinite clip view: \(self)")
//		#endif
	}

	func internal_clipRecenterOffset() -> CGPoint {
		//
		//           ┌──────────────────────────────────────────────────────────────────────────────────┐
		//           │Document View                            △                                        │
		//           │                                                                                  │
		//           │                                         │                                        │
		//           │                                                                                  │
		//           │                                         │                                        │
		//           │                                           maxVerticalDistance                    │
		//           │                                         │                                        │
		//           │                                                                                  │
		//           │                                         │                                        │
		//     ▲     │                                         ▽                                        │
		//     │     │                             ┌──────────────────────┐                             │
		//     │     │                             │                      │                             │
		//     │     │    minHorizontalDistance    │                      │    maxHorizontalDistance    │
		//     │     │◁ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ▷│      Clip View       │◁ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ▷│
		//     │     │                             │                      │                             │
		//     │     │                             │                      │                             │
		//     │     │                             └──────────────────────┘                             │
		//     │     │                                         △                                        │
		//     │     │                                                                                  │
		//     │     │                                         │                                        │
		//     │     │                                                                                  │
		//     │     │                                         │ minVerticalDistance                    │
		//     │     │                                                                                  │
		//     │     │                                         │                                        │
		//     │     │                                                                                  │
		//     │     │                                         │                                        │
		//     │     │                                         ▽                                        │
		//     │     └──────────────────────────────────────────────────────────────────────────────────┘
		//     │
		//     │
		// X───┼─────────────────────────────────────▶
		//     │
		//     Y
		//
		// Created with [Monodraw](https://monodraw.helftone.com)
		//

		assert(Thread.isMainThread)

		guard let docView = self.documentView else { return .zero }
		let docFrame = docView.frame
		let clipBounds = self.bounds

		// Compute the distances to the edges, if any of these values gets less than or equal to zero,
		// then the scroll view edge has been hit and the recenter threshold has to be increased.
		let minHorizontalDistance = clipBounds.minX - docFrame.minX
		let maxHorizontalDistance = docFrame.maxX - clipBounds.maxX
		let minVerticalDistance = clipBounds.minY - docFrame.minY
		let maxVerticalDistance = docFrame.maxY - clipBounds.maxY

		// The threshold needs to be larger than the maximum single scroll distance (otherwise the scroll
		// edge will be hit). Through experimentation, all values stayed below 500.0.
		let HTRecenterThreshold: CGFloat = 500.0

		if
			minHorizontalDistance < HTRecenterThreshold ||
			maxHorizontalDistance < HTRecenterThreshold ||
			minVerticalDistance < HTRecenterThreshold ||
			maxVerticalDistance < HTRecenterThreshold
		{
			// Compute desired clip origin and then just return the offset from current origin.
			let recenterClipOrigin = CGPoint(
				x: docFrame.minX + ((docFrame.size.width - clipBounds.size.width) / 2.0).rounded(.towardZero),
				y: docFrame.minY + ((docFrame.size.height - clipBounds.size.height) / 2.0).rounded(.towardZero)
			)
			return CGPoint(
				x: recenterClipOrigin.x - clipBounds.origin.x,
				y: recenterClipOrigin.y - clipBounds.origin.y
			)
		}

		return .zero
	}

	func internal_scheduleRecenter() {
		assert(Thread.isMainThread)
		if self.recenterScheduled || self.inRecenter {
			return
		}

		self.recenterScheduled = true
		DispatchQueue.main.async { [weak self] in
			guard let `self` = self else { return }
			self.recenterScheduled = false
			self.recenterClipView()
		}
	}

	override public func scroll(_ point: NSPoint) {
		// NSScrollView implements smooth scrolling _only_ for mouse wheel event. This happens inside -scrollToPoint:
		// which will cache the call and subsequently update the bounds. Unfortunately, if we recenter while
		// in a smooth scroll, the scroll view will keep scrolling but will not take into account the recenter.
		// Smooth scrolling can be disabled for an app using NSScrollAnimationEnabled.
		//
		// In order to workaround the issue, we just bypass smooth scrolling and directly scroll.
		//
		// NB: we cannot recenter from here, nsscrollview screws it up if we use a trackpad
		self.setBoundsOrigin(point)
	}
}
