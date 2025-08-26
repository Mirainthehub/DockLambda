import Cocoa
import ServiceManagement

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Properties
    
    private var statusItemController: StatusItemController!
    private var petWindowController: PetWindowController!
    private var dockObserver: DockObserver!
    private var cpuMonitor: CPUUsageMonitor!
    
    // MARK: - Application Lifecycle
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupApplication()
        initializeComponents()
        startMonitoring()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        cleanup()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Show pet window if hidden
        petWindowController.showWindow(nil)
        return true
    }
    
    // MARK: - Private Methods
    
    private func setupApplication() {
        NSApplication.shared.setActivationPolicy(.accessory)
        
        // Listen for screen parameter changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }
    
    private func initializeComponents() {
        // Initialize CPU monitor
        cpuMonitor = CPUUsageMonitor()
        
        // Initialize dock observer
        dockObserver = DockObserver()
        
        // Initialize pet window controller
        petWindowController = PetWindowController()
        petWindowController.loadWindow()
        petWindowController.showWindow(nil)
        
        // Initialize status bar item
        statusItemController = StatusItemController(
            petWindowController: petWindowController,
            dockObserver: dockObserver
        )
        
        // Connect CPU monitor to pet scene
        if let petScene = petWindowController.petScene {
            cpuMonitor.delegate = petScene
        }
    }
    
    private func startMonitoring() {
        dockObserver.startObserving { [weak self] in
            self?.repositionPetWindow()
        }
        cpuMonitor.startMonitoring()
    }
    
    private func cleanup() {
        dockObserver.stopObserving()
        cpuMonitor.stopMonitoring()
    }
    
    @objc private func screenParametersDidChange() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.repositionPetWindow()
        }
    }
    
    private func repositionPetWindow() {
        petWindowController.repositionWindow()
    }
}