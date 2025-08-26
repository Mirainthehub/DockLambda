import SpriteKit
import Cocoa

protocol CPUUsageDelegate: AnyObject {
    func didUpdateCPUUsage(_ usage: Double)
}

final class PetScene: SKScene, CPUUsageDelegate {
    
    // MARK: - Properties
    
    private var petStateMachine: PetStateMachine!
    private var spriteLoader: SpriteLoader!
    private var petSprite: SKSpriteNode!
    
    private var idleTimer: Timer?
    private var currentCPUUsage: Double = 0.0
    
    // MARK: - Initialization
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScene()
        setupPet()
        startIdleTimer()
    }
    
    private func setupScene() {
        backgroundColor = NSColor.clear
        scaleMode = .aspectFit
    }
    
    private func setupPet() {
        // Initialize sprite loader
        spriteLoader = SpriteLoader()
        
        // Initialize state machine
        petStateMachine = PetStateMachine()
        petStateMachine.delegate = self
        
        // Create pet sprite
        createPetSprite()
        
        // Start with idle state
        petStateMachine.setState(.idle)
    }
    
    private func createPetSprite() {
        // Try to load initial sprite
        let initialTexture = spriteLoader.getTexture(for: .idle, frameIndex: 0)
        petSprite = SKSpriteNode(texture: initialTexture)
        petSprite.size = CGSize(width: 80, height: 80)
        petSprite.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(petSprite)
    }
    
    private func startIdleTimer() {
        idleTimer?.invalidate()
        
        // Random idle interval (10-30 seconds)
        let interval = Double.random(in: 10...30)
        idleTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.handleIdleTimeout()
        }
    }
    
    // MARK: - Public Methods
    
    func triggerFeed() {
        petStateMachine.handleEvent(.feed)
        resetIdleTimer()
    }
    
    func triggerDance() {
        petStateMachine.handleEvent(.dance)
        resetIdleTimer()
    }
    
    func triggerJoy() {
        // Wiggle animation for file drop
        let wiggle = SKAction.sequence([
            SKAction.rotate(byAngle: 0.1, duration: 0.1),
            SKAction.rotate(byAngle: -0.2, duration: 0.1),
            SKAction.rotate(byAngle: 0.1, duration: 0.1),
            SKAction.rotate(toAngle: 0, duration: 0.1)
        ])
        petSprite.run(wiggle)
        resetIdleTimer()
    }
    
    // MARK: - CPUUsageDelegate
    
    func didUpdateCPUUsage(_ usage: Double) {
        currentCPUUsage = usage
        
        // Adjust idle animation frequency based on CPU usage
        if usage > 0.8 {
            // High CPU - more frequent animations
            petStateMachine.setIdleFrequency(.high)
        } else if usage > 0.5 {
            petStateMachine.setIdleFrequency(.medium)
        } else {
            petStateMachine.setIdleFrequency(.low)
        }
    }
    
    // MARK: - Private Methods
    
    private func resetIdleTimer() {
        startIdleTimer()
    }
    
    private func handleIdleTimeout() {
        // Randomly choose between sleep or stay idle
        if Bool.random() {
            petStateMachine.handleEvent(.sleep)
        } else {
            petStateMachine.handleEvent(.idle)
        }
        startIdleTimer()
    }
}

// MARK: - PetStateMachineDelegate

extension PetScene: PetStateMachineDelegate {
    func stateMachine(_ stateMachine: PetStateMachine, didChangeToState state: PetState) {
        playAnimationForState(state)
    }
    
    private func playAnimationForState(_ state: PetState) {
        // Stop any current animation
        petSprite.removeAllActions()
        
        // Get textures for the state
        let textures = spriteLoader.getTextures(for: state)
        
        if textures.isEmpty {
            // Fallback to placeholder
            showPlaceholderForState(state)
            return
        }
        
        // Create animation
        let animationDuration = getAnimationDuration(for: state)
        let animate = SKAction.animate(with: textures, timePerFrame: animationDuration / Double(textures.count))
        
        if state == .idle {
            // Repeat idle animation
            let repeatForever = SKAction.repeatForever(animate)
            petSprite.run(repeatForever, withKey: "stateAnimation")
        } else {
            // Play animation once, then return to idle
            let sequence = SKAction.sequence([
                animate,
                SKAction.run { [weak self] in
                    self?.petStateMachine.setState(.idle)
                }
            ])
            petSprite.run(sequence, withKey: "stateAnimation")
        }
    }
    
    private func getAnimationDuration(for state: PetState) -> Double {
        switch state {
        case .idle:
            return 2.0
        case .walk:
            return 1.0
        case .sleep:
            return 3.0
        case .eat:
            return 1.5
        case .dance:
            return 2.5
        }
    }
    
    private func showPlaceholderForState(_ state: PetState) {
        // Create a simple colored rectangle with text as placeholder
        let placeholder = SKShapeNode(rectOf: CGSize(width: 80, height: 80))
        placeholder.fillColor = getColorForState(state)
        placeholder.strokeColor = NSColor.white
        placeholder.lineWidth = 2
        
        // Add state label
        let label = SKLabelNode(text: state.rawValue.uppercased())
        label.fontSize = 10
        label.fontColor = NSColor.white
        label.fontName = "Helvetica-Bold"
        label.position = CGPoint(x: 0, y: -5)
        placeholder.addChild(label)
        
        // Replace pet sprite temporarily
        let originalPosition = petSprite.position
        petSprite.removeFromParent()
        
        placeholder.position = originalPosition
        addChild(placeholder)
        
        // Simple animation for placeholder
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        
        if state == .idle {
            placeholder.run(SKAction.repeatForever(pulse))
        } else {
            placeholder.run(pulse) {
                placeholder.removeFromParent()
                self.addChild(self.petSprite)
                self.petStateMachine.setState(.idle)
            }
        }
        
        print("⚠️ Missing sprites for state: \(state). Using placeholder.")
    }
    
    private func getColorForState(_ state: PetState) -> NSColor {
        switch state {
        case .idle:
            return NSColor.systemBlue
        case .walk:
            return NSColor.systemGreen
        case .sleep:
            return NSColor.systemPurple
        case .eat:
            return NSColor.systemOrange
        case .dance:
            return NSColor.systemPink
        }
    }
}