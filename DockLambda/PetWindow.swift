import Cocoa
import SpriteKit

final class PetWindow: NSWindow {
    
    // MARK: - Properties
    
    private var isDragging = false
    private var dragStartLocation: CGPoint = .zero
    private var originalFrameOrigin: CGPoint = .zero
    
    // MARK: - Initialization
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        setupWindow()
    }
    
    private func setupWindow() {
        // Make window accept mouse events
        acceptsMouseMovedEvents = true
        
        // Setup tracking area for mouse events
        let trackingArea = NSTrackingArea(
            rect: frame,
            options: [.activeAlways, .mouseMoved, .mouseEnteredAndExited],
            owner: self,
            userInfo: nil
        )
        contentView?.addTrackingArea(trackingArea)
    }
    
    // MARK: - Mouse Events
    
    override func mouseDown(with event: NSEvent) {
        // Handle double-click first
        if event.clickCount == 2 {
            // Double click - trigger dance action
            if let petScene = (contentView as? SKView)?.scene as? PetScene {
                petScene.triggerDance()
            }
            return
        }
        
        super.mouseDown(with: event)
        
        // Check if Option key is pressed for dragging
        if event.modifierFlags.contains(.option) {
            startDragging(with: event)
        } else {
            // Single click - trigger feed action
            if let petScene = (contentView as? SKView)?.scene as? PetScene {
                petScene.triggerFeed()
            }
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        
        if isDragging {
            endDragging()
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        
        if isDragging {
            continueDragging(with: event)
        }
    }
    
    override func rightMouseDown(with event: NSEvent) {
        super.rightMouseDown(with: event)
        // Could show context menu here if needed
    }
    
    // MARK: - Dragging
    
    private func startDragging(with event: NSEvent) {
        // Check if position is locked
        if UserDefaults.standard.bool(forKey: "lockPosition") {
            return
        }
        
        isDragging = true
        dragStartLocation = event.locationInWindow
        originalFrameOrigin = frame.origin
        
        // Change cursor to indicate dragging
        NSCursor.closedHand.set()
    }
    
    private func continueDragging(with event: NSEvent) {
        guard isDragging else { return }
        
        let currentLocation = event.locationInWindow
        let deltaX = currentLocation.x - dragStartLocation.x
        let deltaY = currentLocation.y - dragStartLocation.y
        
        let newOrigin = CGPoint(
            x: originalFrameOrigin.x + deltaX,
            y: originalFrameOrigin.y + deltaY
        )
        
        setFrameOrigin(newOrigin)
    }
    
    private func endDragging() {
        guard isDragging else { return }
        
        isDragging = false
        NSCursor.arrow.set()
        
        // Save the new relative offset
        if let windowController = windowController as? PetWindowController {
            let currentOrigin = frame.origin
            let offset = CGPoint(
                x: currentOrigin.x - originalFrameOrigin.x,
                y: currentOrigin.y - originalFrameOrigin.y
            )
            windowController.saveRelativeOffset(offset)
        }
    }
    
    // MARK: - Window Behavior
    
    override var canBecomeKey: Bool {
        return false
    }
    
    override var canBecomeMain: Bool {
        return false
    }
    
    override func resignMain() {
        super.resignMain()
        // Ensure window stays visible
    }
    
    override func resignKey() {
        super.resignKey()
        // Ensure window stays responsive
    }
}