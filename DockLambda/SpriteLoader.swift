import SpriteKit
import Cocoa

final class SpriteLoader {
    
    // MARK: - Properties
    
    private var textureCache: [String: SKTexture] = [:]
    private let spritesDirectoryName = "Sprites"
    
    // MARK: - Initialization
    
    init() {
        loadPlaceholderSprites()
    }
    
    // MARK: - Public Methods
    
    func getTextures(for state: PetState) -> [SKTexture] {
        let stateDirectory = state.rawValue
        var textures: [SKTexture] = []
        
        // Try to load sprite files
        for i in 0..<10 { // Try up to 10 frames
            if let texture = loadTexture(state: state, frameIndex: i) {
                textures.append(texture)
            } else if i == 0 {
                // If even the first frame is missing, create placeholder
                let placeholder = createPlaceholderTexture(for: state)
                textures.append(placeholder)
                break
            } else {
                // No more frames for this state
                break
            }
        }
        
        return textures
    }
    
    func getTexture(for state: PetState, frameIndex: Int) -> SKTexture? {
        let cacheKey = "\(state.rawValue)_\(frameIndex)"
        
        if let cachedTexture = textureCache[cacheKey] {
            return cachedTexture
        }
        
        if let texture = loadTexture(state: state, frameIndex: frameIndex) {
            textureCache[cacheKey] = texture
            return texture
        }
        
        // Return placeholder
        let placeholder = createPlaceholderTexture(for: state)
        textureCache[cacheKey] = placeholder
        return placeholder
    }
    
    // MARK: - Private Methods
    
    private func loadTexture(state: PetState, frameIndex: Int) -> SKTexture? {
        let fileName = "\(state.rawValue)_\(frameIndex)"
        
        // Try different extensions
        for ext in ["png", "PNG", "jpg", "JPG"] {
            let fullFileName = "\(fileName).\(ext)"
            
            // Check in app bundle first
            if let imagePath = Bundle.main.path(forResource: fileName, ofType: ext),
               let image = NSImage(contentsOfFile: imagePath) {
                return SKTexture(image: image)
            }
            
            // Check in Sprites subdirectory
            if let imagePath = Bundle.main.path(forResource: fileName, ofType: ext, inDirectory: "Sprites/\(state.rawValue)"),
               let image = NSImage(contentsOfFile: imagePath) {
                return SKTexture(image: image)
            }
        }
        
        return nil
    }
    
    private func createPlaceholderTexture(for state: PetState) -> SKTexture {
        let size = CGSize(width: 80, height: 80)
        let color = getPlaceholderColor(for: state)
        
        let image = NSImage(size: size)
        image.lockFocus()
        
        // Draw colored rectangle
        color.setFill()
        NSRect(origin: .zero, size: size).fill()
        
        // Draw border
        NSColor.white.setStroke()
        let borderRect = NSRect(origin: .zero, size: size)
        borderRect.frame()
        
        // Draw text
        let text = state.rawValue.uppercased()
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.white,
            .font: NSFont.boldSystemFont(ofSize: 12)
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.size()
        let textRect = NSRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        attributedString.draw(in: textRect)
        
        image.unlockFocus()
        
        return SKTexture(image: image)
    }
    
    private func getPlaceholderColor(for state: PetState) -> NSColor {
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
    
    private func loadPlaceholderSprites() {
        // Generate basic placeholder sprites for first run
        generatePlaceholderSpritesIfNeeded()
    }
    
    private func generatePlaceholderSpritesIfNeeded() {
        let spritesPath = getSpritesDirectory()
        
        for state in PetState.allCases {
            let stateDirectory = spritesPath.appendingPathComponent(state.rawValue)
            
            // Check if directory exists and has sprites
            if !FileManager.default.fileExists(atPath: stateDirectory.path) {
                print("📁 Creating sprites directory: \(state.rawValue)")
                try? FileManager.default.createDirectory(at: stateDirectory, withIntermediateDirectories: true)
                
                // Generate a placeholder sprite
                generatePlaceholderSprite(for: state, in: stateDirectory)
            }
        }
    }
    
    private func getSpritesDirectory() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let spritesPath = documentsPath.appendingPathComponent("DockLambda").appendingPathComponent("Sprites")
        
        try? FileManager.default.createDirectory(at: spritesPath, withIntermediateDirectories: true)
        return spritesPath
    }
    
    private func generatePlaceholderSprite(for state: PetState, in directory: URL) {
        let size = CGSize(width: 80, height: 80)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // Draw colored circle/shape
        let color = getPlaceholderColor(for: state)
        color.setFill()
        
        let rect = NSRect(origin: .zero, size: size).insetBy(dx: 8, dy: 8)
        let path = NSBezierPath(ovalIn: rect)
        path.fill()
        
        // Draw simple face
        NSColor.white.setFill()
        // Eyes
        let eyeSize: CGFloat = 6
        NSBezierPath(ovalIn: NSRect(x: 25, y: 50, width: eyeSize, height: eyeSize)).fill()
        NSBezierPath(ovalIn: NSRect(x: 49, y: 50, width: eyeSize, height: eyeSize)).fill()
        
        // Mouth
        let mouth = NSBezierPath()
        mouth.move(to: NSPoint(x: 30, y: 35))
        mouth.curve(to: NSPoint(x: 50, y: 35), controlPoint1: NSPoint(x: 35, y: 30), controlPoint2: NSPoint(x: 45, y: 30))
        mouth.lineWidth = 2
        mouth.stroke()
        
        image.unlockFocus()
        
        // Save to file
        let fileName = "\(state.rawValue)_0.png"
        let filePath = directory.appendingPathComponent(fileName)
        
        if let data = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: data),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            try? pngData.write(to: filePath)
            print("✅ Generated placeholder sprite: \(fileName)")
        }
    }
}