import ServiceManagement
import Foundation

final class StartAtLoginHelper {
    
    // MARK: - Properties
    
    private let service = SMAppService.mainApp
    
    // MARK: - Public Methods
    
    var isEnabled: Bool {
        return service.status == .enabled
    }
    
    func enable() {
        do {
            try service.register()
            print("✅ Start at login enabled")
        } catch {
            print("❌ Failed to enable start at login: \(error)")
            showStartAtLoginError(error)
        }
    }
    
    func disable() {
        do {
            try service.unregister()
            print("✅ Start at login disabled")
        } catch {
            print("❌ Failed to disable start at login: \(error)")
            showStartAtLoginError(error)
        }
    }
    
    // MARK: - Private Methods
    
    private func showStartAtLoginError(_ error: Error) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Start at Login Error"
            alert.informativeText = self.getErrorMessage(error)
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            
            if let window = NSApplication.shared.keyWindow {
                alert.beginSheetModal(for: window) { _ in }
            } else {
                alert.runModal()
            }
        }
    }
    
    private func getErrorMessage(_ error: Error) -> String {
        if let smError = error as? SMAppService.Error {
            switch smError {
            case .bundleNotFound:
                return "Application bundle not found. This usually happens in development."
            case .duplicateJob:
                return "Login item already exists."
            case .jobNotFound:
                return "Login item not found."
            case .notAuthorized:
                return "Not authorized to modify login items. Please try again."
            @unknown default:
                return "Unknown error: \(smError.localizedDescription)"
            }
        }
        return error.localizedDescription
    }
    
    // MARK: - Status Checking
    
    var statusDescription: String {
        switch service.status {
        case .enabled:
            return "Enabled"
        case .requiresApproval:
            return "Requires Approval"
        case .notRegistered:
            return "Not Registered"
        case .notFound:
            return "Not Found"
        @unknown default:
            return "Unknown"
        }
    }
    
    func checkStatus() {
        print("🚀 Start at login status: \(statusDescription)")
        
        if service.status == .requiresApproval {
            showApprovalRequiredMessage()
        }
    }
    
    private func showApprovalRequiredMessage() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Approval Required"
            alert.informativeText = "DockLambda requires approval to start at login. Please open System Preferences > General > Login Items to approve."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Open System Preferences")
            alert.addButton(withTitle: "Later")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                self.openLoginItemsPreferences()
            }
        }
    }
    
    private func openLoginItemsPreferences() {
        if #available(macOS 13.0, *) {
            // macOS 13+ path
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension")!)
        } else {
            // Fallback for older versions
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.users")!)
        }
    }
}