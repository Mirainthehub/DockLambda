import Cocoa
import SpriteKit

final class PetWindowController: NSWindowController {
    
    // MARK: - Properties
    
    private var petWindow: PetWindow!
    private var skView: SKView!
    private(set) var petScene: PetScene!
    private var dragDropHandler: DragDropHandler!
    
    private let petSize = CGSize(width: 120, height: 120)
    
    // MARK: - Initialization
    
    override init(window: NSWindow?) {
        super.init(window: window)
        setupWindow()
        setupScene()
        setupDragDrop()
        loadUserDefaults()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWindow()
        setupScene()
        setupDragDrop()
        loadUserDefaults()
    }
    
    convenience init() {
        self.init(window: nil)
    }
    
    // MARK: - Window Management
    
    override func loadWindow() {
        if window == nil {
            setupWindow()
        }
    }
    
    private func setupWindow() {
        petWindow = PetWindow(
            contentRect: NSRect(origin: .zero, size: petSize),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        // Configure window properties
        petWindow.isOpaque = false
        petWindow.backgroundColor = NSColor.clear
        petWindow.level = .floating
        petWindow.collectionBehavior = [.canJoinAllSpaces, .stationary]
        petWindow.isMovableByWindowBackground = false
        petWindow.hasShadow = false
        petWindow.ignoresMouseEvents = false
        
        // Set as main window
        self.window = petWindow
        
        // Position window
        repositionWindow()
    }
    
    private func setupScene() {
        // Create SKView
        skView = SKView(frame: NSRect(origin: .zero, size: petSize))
        skView.allowsTransparency = true
        skView.ignoresSiblingOrder = true
        
        // Create PetScene
        petScene = PetScene(size: petSize)
        petScene.scaleMode = .aspectFit
        petScene.backgroundColor = NSColor.clear
        
        // Present scene
        skView.presentScene(petScene)
        
        // Add to window
        petWindow.contentView = skView
    }
    
    private func setupDragDrop() {
        dragDropHandler = DragDropHandler(petScene: petScene)
        skView.registerForDraggedTypes([.fileURL])
        skView.addSubview(dragDropHandler)
    }
    
    private func loadUserDefaults() {
        let clickThrough = UserDefaults.standard.bool(forKey: "clickThrough")
        setClickThrough(clickThrough)
    }
    
    // MARK: - Public Methods
    
    func repositionWindow() {
        guard let screen = NSScreen.main else { return }
        
        let dockOrientation = DockObserver.getDockOrientation()
        let visibleFrame = screen.visibleFrame
        let screenFrame = screen.frame
        
        let margin: CGFloat = 12
        var windowOrigin: CGPoint
        
        switch dockOrientation {
        case .bottom:
            windowOrigin = CGPoint(
                x: visibleFrame.maxX - petSize.width - margin,
                y: visibleFrame.minY + margin
            )
        case .left:
            windowOrigin = CGPoint(
                x: visibleFrame.minX + margin,
                y: visibleFrame.minY + margin
            )
        case .right:
            windowOrigin = CGPoint(
                x: visibleFrame.maxX - petSize.width - margin,
                y: visibleFrame.minY + margin
            )
        }
        
        // Apply user offset if exists
        if let offsetData = UserDefaults.standard.data(forKey: "relativeOffset"),
           let offset = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSValue.self, from: offsetData) {
            let offsetPoint = offset.pointValue
            windowOrigin.x += offsetPoint.x
            windowOrigin.y += offsetPoint.y
        }
        
        // Ensure window stays on screen
        windowOrigin.x = max(0, min(windowOrigin.x, screenFrame.maxX - petSize.width))
        windowOrigin.y = max(0, min(windowOrigin.y, screenFrame.maxY - petSize.height))
        
        petWindow.setFrameOrigin(windowOrigin)
    }
    
    func setClickThrough(_ enabled: Bool) {
        petWindow.ignoresMouseEvents = enabled
        UserDefaults.standard.set(enabled, forKey: "clickThrough")
    }
    
    func saveRelativeOffset(_ offset: CGPoint) {
        let offsetValue = NSValue(point: offset)
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: offsetValue, requiringSecureCoding: true) {
            UserDefaults.standard.set(data, forKey: "relativeOffset")
        }
    }
}