import Cocoa
import Foundation

enum DockOrientation {
    case left, bottom, right
}

final class DockObserver {
    
    // MARK: - Properties
    
    private var observationTimer: Timer?
    private var lastDockOrientation: DockOrientation?
    private var changeHandler: (() -> Void)?
    
    // MARK: - Public Methods
    
    func startObserving(changeHandler: @escaping () -> Void) {
        self.changeHandler = changeHandler
        self.lastDockOrientation = Self.getDockOrientation()
        
        // Start periodic checking (every 3 seconds)
        observationTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.checkForDockChanges()
        }
    }
    
    func stopObserving() {
        observationTimer?.invalidate()
        observationTimer = nil
        changeHandler = nil
    }
    
    static func getDockOrientation() -> DockOrientation {
        // Try to read from dock preferences
        if let orientation = CFPreferencesCopyAppValue("orientation" as CFString, "com.apple.dock" as CFString) as? String {
            switch orientation.lowercased() {
            case "left":
                return .left
            case "right":
                return .right
            case "bottom":
                return .bottom
            default:
                return .bottom
            }
        }
        
        // Fallback: determine by comparing screen frame vs visible frame
        guard let screen = NSScreen.main else { return .bottom }
        let screenFrame = screen.frame
        let visibleFrame = screen.visibleFrame
        
        // Check if dock is on left
        if visibleFrame.minX > screenFrame.minX {
            return .left
        }
        
        // Check if dock is on right
        if visibleFrame.maxX < screenFrame.maxX {
            return .right
        }
        
        // Default to bottom
        return .bottom
    }
    
    // MARK: - Private Methods
    
    private func checkForDockChanges() {
        let currentOrientation = Self.getDockOrientation()
        
        if currentOrientation != lastDockOrientation {
            lastDockOrientation = currentOrientation
            
            // Notify on main queue
            DispatchQueue.main.async { [weak self] in
                self?.changeHandler?()
            }
        }
    }
}

// MARK: - DockOrientation Extension

extension DockOrientation: Equatable {
    static func == (lhs: DockOrientation, rhs: DockOrientation) -> Bool {
        switch (lhs, rhs) {
        case (.left, .left), (.bottom, .bottom), (.right, .right):
            return true
        default:
            return false
        }
    }
}

extension DockOrientation: CustomStringConvertible {
    var description: String {
        switch self {
        case .left:
            return "left"
        case .bottom:
            return "bottom"
        case .right:
            return "right"
        }
    }
}