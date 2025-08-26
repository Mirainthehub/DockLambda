import Cocoa

final class DragDropHandler: NSView {
    
    // MARK: - Properties
    
    private weak var petScene: PetScene?
    
    // MARK: - Initialization
    
    init(petScene: PetScene) {
        self.petScene = petScene
        super.init(frame: .zero)
        
        setupDragDrop()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDragDrop()
    }
    
    // MARK: - Setup
    
    private func setupDragDrop() {
        registerForDraggedTypes([.fileURL])
        isHidden = true // Transparent overlay
    }
    
    // MARK: - Drag & Drop
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        // Check if we have file URLs
        if let _ = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] {
            return .copy
        }
        return []
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] else {
            return false
        }
        
        // Process dropped files
        handleDroppedFiles(urls)
        
        return true
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        // Could add visual feedback here
    }
    
    // MARK: - File Handling
    
    private func handleDroppedFiles(_ urls: [URL]) {
        print("📁 Files dropped on pet: \(urls.map { $0.lastPathComponent })")
        
        // Trigger joy/wiggle animation
        petScene?.triggerJoy()
        
        // Could add specific file type handling here
        for url in urls {
            handleSpecificFile(url)
        }
    }
    
    private func handleSpecificFile(_ url: URL) {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "png", "jpg", "jpeg", "gif":
            handleImageFile(url)
        case "txt", "md", "rtf":
            handleTextFile(url)
        case "mp3", "wav", "m4a":
            handleAudioFile(url)
        case "mov", "mp4", "avi":
            handleVideoFile(url)
        default:
            handleGenericFile(url)
        }
    }
    
    private func handleImageFile(_ url: URL) {
        print("🖼️ Image file dropped: \(url.lastPathComponent)")
        // Could show special animation for images
    }
    
    private func handleTextFile(_ url: URL) {
        print("📝 Text file dropped: \(url.lastPathComponent)")
        // Could read and process text files
    }
    
    private func handleAudioFile(_ url: URL) {
        print("🎵 Audio file dropped: \(url.lastPathComponent)")
        // Could trigger dance animation
        petScene?.triggerDance()
    }
    
    private func handleVideoFile(_ url: URL) {
        print("🎬 Video file dropped: \(url.lastPathComponent)")
        // Could trigger special video reaction
    }
    
    private func handleGenericFile(_ url: URL) {
        print("📄 File dropped: \(url.lastPathComponent)")
        // Generic file handling
    }
}

// MARK: - NSView Override

extension DragDropHandler {
    override var acceptsFirstResponder: Bool {
        return false
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        // Always pass through to underlying view for normal interactions
        return nil
    }
}