import Cocoa

final class StatusItemController {
    
    // MARK: - Properties
    
    private let statusItem: NSStatusItem
    private let petWindowController: PetWindowController
    private let dockObserver: DockObserver
    private let startAtLoginHelper: StartAtLoginHelper?
    
    // MARK: - Initialization
    
    init(petWindowController: PetWindowController, dockObserver: DockObserver) {
        print("🔄 StatusItemController initializing...")
        self.petWindowController = petWindowController
        self.dockObserver = dockObserver
        
        // Only initialize StartAtLoginHelper on macOS 13+
        if #available(macOS 13.0, *) {
            self.startAtLoginHelper = StartAtLoginHelper()
            print("✅ StartAtLoginHelper initialized")
        } else {
            self.startAtLoginHelper = nil
            print("⚠️  StartAtLoginHelper not available (macOS < 13)")
        }
        
        print("🔄 Creating NSStatusBar item...")
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if statusItem.button != nil {
            print("✅ Status bar item created successfully")
            setupStatusItem()
            setupMenu()
        } else {
            print("❌ Failed to create status bar item!")
        }
    }
    
    // MARK: - Private Methods
    
    private func setupStatusItem() {
        print("🔄 Setting up status item appearance...")
        statusItem.button?.title = "λ"
        statusItem.button?.font = NSFont.systemFont(ofSize: 16, weight: .medium)
        print("✅ Status item appearance configured")
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        
        // Toggle Click-Through
        let clickThroughItem = NSMenuItem(
            title: "Toggle Click-Through",
            action: #selector(toggleClickThrough),
            keyEquivalent: "t"
        )
        clickThroughItem.target = self
        menu.addItem(clickThroughItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Lock Position
        let lockPositionItem = NSMenuItem(
            title: "Lock Position",
            action: #selector(toggleLockPosition),
            keyEquivalent: "l"
        )
        lockPositionItem.target = self
        menu.addItem(lockPositionItem)
        
        // Reset Position
        let resetPositionItem = NSMenuItem(
            title: "Reset Position",
            action: #selector(resetPosition),
            keyEquivalent: "r"
        )
        resetPositionItem.target = self
        menu.addItem(resetPositionItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Start at Login
        let startAtLoginItem = NSMenuItem(
            title: "Start at Login",
            action: #selector(toggleStartAtLogin),
            keyEquivalent: ""
        )
        startAtLoginItem.target = self
        menu.addItem(startAtLoginItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Show/Hide Pet
        let showHideItem = NSMenuItem(
            title: "Show Pet",
            action: #selector(togglePetVisibility),
            keyEquivalent: "p"
        )
        showHideItem.target = self
        menu.addItem(showHideItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(
            title: "Quit DockLambda",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
        
        // Update menu state
        updateMenuItems()
    }
    
    private func updateMenuItems() {
        guard let menu = statusItem.menu else { return }
        
        // Update click-through state
        if let clickThroughItem = menu.item(withTitle: "Toggle Click-Through") {
            let isClickThrough = UserDefaults.standard.bool(forKey: "clickThrough")
            clickThroughItem.state = isClickThrough ? .on : .off
        }
        
        // Update lock position state
        if let lockItem = menu.item(withTitle: "Lock Position") {
            let isLocked = UserDefaults.standard.bool(forKey: "lockPosition")
            lockItem.state = isLocked ? .on : .off
        }
        
        // Update start at login state
        if let startAtLoginItem = menu.item(withTitle: "Start at Login") {
            if let helper = startAtLoginHelper {
                startAtLoginItem.state = helper.isEnabled ? .on : .off
                startAtLoginItem.isEnabled = true
            } else {
                startAtLoginItem.state = .off
                startAtLoginItem.isEnabled = false
                startAtLoginItem.title = "Start at Login (macOS 13+ only)"
            }
        }
        
        // Update show/hide state
        if let showHideItem = menu.item(withTitle: "Show Pet") ?? menu.item(withTitle: "Hide Pet") {
            let isVisible = petWindowController.window?.isVisible ?? false
            showHideItem.title = isVisible ? "Hide Pet" : "Show Pet"
        }
    }
    
    // MARK: - Menu Actions
    
    @objc private func toggleClickThrough() {
        let current = UserDefaults.standard.bool(forKey: "clickThrough")
        let new = !current
        UserDefaults.standard.set(new, forKey: "clickThrough")
        petWindowController.setClickThrough(new)
        updateMenuItems()
    }
    
    @objc private func toggleLockPosition() {
        let current = UserDefaults.standard.bool(forKey: "lockPosition")
        let new = !current
        UserDefaults.standard.set(new, forKey: "lockPosition")
        updateMenuItems()
    }
    
    @objc private func resetPosition() {
        UserDefaults.standard.removeObject(forKey: "relativeOffset")
        petWindowController.repositionWindow()
    }
    
    @objc private func toggleStartAtLogin() {
        guard let helper = startAtLoginHelper else {
            // Show alert for unsupported macOS version
            let alert = NSAlert()
            alert.messageText = "Unsupported macOS Version"
            alert.informativeText = "Start at Login feature requires macOS 13.0 or later."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return
        }
        
        if helper.isEnabled {
            helper.disable()
        } else {
            helper.enable()
        }
        updateMenuItems()
    }
    
    @objc private func togglePetVisibility() {
        if petWindowController.window?.isVisible == true {
            petWindowController.window?.orderOut(nil)
        } else {
            petWindowController.showWindow(nil)
        }
        updateMenuItems()
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}