//
//  PopoverButon.swift
//  Lunar
//
//  Created by Alin Panaitiu on 23.12.2020.
//  Copyright © 2020 Alin. All rights reserved.
//

import Cocoa
import Foundation

// MARK: - PopoverButton

class PopoverButton<T: NSViewController>: Button {
    @IBInspectable var showPopover = true

    var popoverKey: String {
        "help"
    }

    var popover: NSPopover? {
        if !POPOVERS.keys.contains(popoverKey) || POPOVERS[popoverKey]! == nil {
            appDelegate!.initPopovers()
        }
        guard let popover = POPOVERS[popoverKey]! else { return nil }
        return popover
    }

    var popoverController: T? {
        popover?.contentViewController as? T
    }

    override func mouseDown(with event: NSEvent) {
        guard let popover = popover, isEnabled else { return }
        handlePopoverClick(popover, with: event)
    }

    func close() {
        popover?.close()
    }

    func open(edge: NSRectEdge = .maxY) {
        guard let popover = popover, (popover.contentViewController as? T) != nil, self.superview?.window != nil else {
            return
        }
        popover.show(relativeTo: visibleRect, of: self, preferredEdge: edge)
        popover.becomeFirstResponder()
    }

    func handlePopoverClick(_ popover: NSPopover, with event: NSEvent) {
        if popover.isShown {
            popover.close()
            return
        }

        guard showPopover else {
            super.mouseDown(with: event)
            return
        }

        if (popover.contentViewController as? T) != nil {
            popover.show(relativeTo: visibleRect, of: self, preferredEdge: .maxY)
            popover.becomeFirstResponder()
        }

        super.mouseDown(with: event)
    }
}

// MARK: - NSSize + Comparable

extension NSSize: Comparable {
    var area: CGFloat { width * height }
    public static func < (lhs: CGSize, rhs: CGSize) -> Bool {
        lhs.area < rhs.area
    }
}

// MARK: - Box

class Box: NSBox {
    // MARK: Lifecycle

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: Internal

    var hover = false

    @IBInspectable var alpha: CGFloat = 0.5 {
        didSet {
            if !hover {
                mainThread {
                    alphaValue = alpha
                }
            }
        }
    }

    @IBInspectable var hoverAlpha: CGFloat = 1.0 {
        didSet {
            if hover {
                mainThread {
                    alphaValue = hoverAlpha
                }
            }
        }
    }

    override var frame: NSRect {
        didSet { trackHover() }
    }

    override var isHidden: Bool {
        didSet { trackHover() }
    }

    func setup() {
        bg = .clear
        alphaValue = alpha

        trackHover()
    }

    override func mouseEntered(with event: NSEvent) {
        if isHidden { return }
        hover = true

        transition(0.2)
        alphaValue = hoverAlpha
        super.mouseEntered(with: event)
    }

    override func mouseExited(with event: NSEvent) {
        if isHidden { return }
        hover = false

        transition(0.4)
        alphaValue = alpha
        super.mouseExited(with: event)
    }
}
