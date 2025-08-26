import Foundation

enum PetState: String, CaseIterable {
    case idle, walk, sleep, eat, dance
}

enum PetEvent {
    case idle, walk, sleep, feed, dance, interact
}

enum IdleFrequency {
    case low, medium, high
}

protocol PetStateMachineDelegate: AnyObject {
    func stateMachine(_ stateMachine: PetStateMachine, didChangeToState state: PetState)
}

final class PetStateMachine {
    
    // MARK: - Properties
    
    private(set) var currentState: PetState = .idle
    private var idleFrequency: IdleFrequency = .low
    
    weak var delegate: PetStateMachineDelegate?
    
    // MARK: - Public Methods
    
    func setState(_ newState: PetState) {
        guard newState != currentState else { return }
        
        currentState = newState
        delegate?.stateMachine(self, didChangeToState: newState)
        
        print("🐱 Pet state changed to: \(newState)")
    }
    
    func handleEvent(_ event: PetEvent) {
        let newState = getNextState(for: event, from: currentState)
        setState(newState)
    }
    
    func setIdleFrequency(_ frequency: IdleFrequency) {
        self.idleFrequency = frequency
    }
    
    // MARK: - Private Methods
    
    private func getNextState(for event: PetEvent, from currentState: PetState) -> PetState {
        switch (currentState, event) {
        // From any state
        case (_, .feed):
            return .eat
        case (_, .dance):
            return .dance
        case (_, .interact):
            return .idle
            
        // State-specific transitions
        case (.idle, .sleep):
            return .sleep
        case (.idle, .walk):
            return .walk
        case (.idle, .idle):
            return .idle
            
        case (.sleep, .idle), (.sleep, .interact):
            return .idle
            
        case (.walk, .idle), (.walk, .interact):
            return .idle
            
        case (.eat, _):
            return .idle
            
        case (.dance, _):
            return .idle
            
        // Default: stay in current state
        default:
            return currentState
        }
    }
    
    // MARK: - State Utilities
    
    var canTransitionToSleep: Bool {
        return currentState == .idle
    }
    
    var canTransitionToWalk: Bool {
        return currentState == .idle
    }
    
    var isIdle: Bool {
        return currentState == .idle
    }
    
    var isInteracting: Bool {
        return currentState == .eat || currentState == .dance
    }
}

// MARK: - PetStateMachine Extensions

extension PetStateMachine: CustomStringConvertible {
    var description: String {
        return "PetStateMachine(currentState: \(currentState), frequency: \(idleFrequency))"
    }
}

extension IdleFrequency: CustomStringConvertible {
    var description: String {
        switch self {
        case .low:
            return "low"
        case .medium:
            return "medium"
        case .high:
            return "high"
        }
    }
}