# DockLambda 🐾

**A charming macOS Dock pet that lives on your desktop!**

DockLambda is a delightful desktop companion that sits near your Dock, providing interactive animations and responding to your activity. Built with Swift 5.9, AppKit, and SpriteKit for macOS 13+.

## 🎯 Features

### 🪟 Smart Window Behavior
- **Transparent, borderless window** that floats above desktop but below apps
- **Automatic Dock positioning** - follows your Dock (left/bottom/right)
- **Cross-desktop presence** - appears on all Spaces/Desktops
- **Click-through mode** - toggle mouse interaction via menu

### 🎭 Interactive Pet Animations
- **5 animated states**: Idle, Walk, Sleep, Eat, Dance
- **Smart state transitions** based on activity and CPU usage
- **Interactive gestures**:
  - Single click → Feed animation
  - Double click → Dance animation  
  - File drag & drop → Joy/wiggle reaction
  - Option+drag → Reposition pet

### ⚙️ System Integration
- **Menu bar control** with λ icon
- **Start at login** support (macOS 13+ SMAppService)
- **CPU usage monitoring** - pet becomes more active under load
- **Multi-monitor aware** with Dock detection
- **Preference persistence** via UserDefaults

### 🎨 Adaptive Graphics
- **SpriteKit animations** with fallback placeholders
- **Missing asset handling** - generates colored placeholders if sprites unavailable
- **Scalable design** - works on different screen densities

## 🚀 Quick Start

### Prerequisites
- **macOS 13.0+**
- **Xcode 15.0+** with Swift 5.9
- **Python 3** (optional, for generating placeholder assets)

### Build & Run

1. **Clone and setup**:
   ```bash
   git clone <repository>
   cd MacLambda
   ```

2. **Generate assets** (optional):
   ```bash
   pip3 install Pillow  # For asset generation
   python3 generate_placeholder_assets.py
   ```

3. **Build and launch**:
   ```bash
   ./build_and_run.sh
   ```
   
   Or open `DockLambda.xcodeproj` in Xcode and press ⌘R

4. **Look for**:
   - Pet window near your Dock
   - λ icon in menu bar

## 🎮 Usage Guide

### Basic Interactions
| Action | Result |
|--------|---------|
| **Single click** | Feed animation (eat state) |
| **Double click** | Dance animation |  
| **Drag files to pet** | Wiggle/joy reaction |
| **Option + drag pet** | Move to custom position |

### Menu Bar Controls
- **Toggle Click-Through**: Enable/disable mouse interaction
- **Lock Position**: Prevent accidental dragging
- **Reset Position**: Return to auto-calculated Dock position
- **Start at Login**: Launch automatically on system boot
- **Show/Hide Pet**: Toggle visibility

### Automatic Behaviors
- **Idle timer**: Pet enters sleep state after inactivity
- **CPU monitoring**: Higher CPU usage → more frequent animations
- **Dock tracking**: Automatically repositions when Dock moves
- **Screen changes**: Adapts to display configuration changes

## 🏗️ Architecture

### Core Components

```swift
AppDelegate.swift           // Main application coordinator
├── StatusItemController    // Menu bar management
├── PetWindowController    // Window lifecycle & positioning
├── PetWindow              // Custom window with mouse handling
├── PetScene               // SpriteKit scene & animations  
├── PetStateMachine        // State transitions & logic
├── SpriteLoader           // Asset loading with fallbacks
├── DockObserver           // Dock position monitoring
├── CPUUsageMonitor        // System performance tracking
├── DragDropHandler        // File drop interactions
└── StartAtLoginHelper     // Login item management
```

### Key Design Patterns
- **State Machine**: Clean animation state management
- **Observer Pattern**: Dock position and system changes
- **Delegate Pattern**: Loose coupling between components
- **Fallback Strategy**: Graceful degradation when assets missing

## 🎨 Customization

### Adding Custom Sprites
1. Create directories: `DockLambda/Sprites/{state}/`
2. Add PNG files: `{state}_0.png`, `{state}_1.png`, etc.
3. Rebuild project - SpriteLoader will automatically detect them

### Modifying Behavior
- **Animation timing**: Edit `getAnimationDuration()` in PetScene
- **State transitions**: Modify `PetStateMachine.swift`
- **CPU thresholds**: Adjust values in `CPUUsageMonitor`
- **Positioning logic**: Update `DockObserver` and `repositionWindow()`

## 🧪 Testing Checklist

### ✅ Basic Functionality
- [ ] App compiles and runs on macOS 13+
- [ ] Pet window appears near Dock with transparent background
- [ ] Menu bar λ icon shows with working menu
- [ ] Single/double click triggers correct animations
- [ ] File drag & drop causes wiggle reaction

### ✅ Dock Integration  
- [ ] Pet repositions when Dock moves (left/bottom/right)
- [ ] Window stays visible across all Spaces/Desktops
- [ ] Position persists across app restarts
- [ ] Option+drag allows custom positioning

### ✅ Menu Controls
- [ ] Toggle Click-Through enables/disables interaction
- [ ] Lock Position prevents dragging
- [ ] Reset Position returns to Dock edge
- [ ] Start at Login registers/unregisters correctly
- [ ] Show/Hide Pet toggles visibility

### ✅ Robustness
- [ ] No crashes with missing sprite assets
- [ ] CPU monitoring doesn't block UI
- [ ] Works correctly on multiple monitors
- [ ] Graceful handling of Dock preference read failures

## 🐛 Common Issues & Solutions

### Issue: Pet doesn't appear
**Solutions:**
- Check if window is off-screen: Menu → Reset Position
- Toggle visibility: Menu → Show Pet
- Restart app: Menu → Quit, then relaunch

### Issue: Menu bar icon missing
**Solutions:**
- App may be running as regular app instead of agent
- Check `Info.plist` has `LSUIElement = true`
- Restart app or reboot system

### Issue: Start at Login not working
**Solutions:**
- First time requires user approval in System Preferences
- Check error messages in Console.app
- Development builds may have limitations

### Issue: Animations are placeholders
**Solutions:**  
- Run asset generation script: `python3 generate_placeholder_assets.py`
- Add custom sprites to `Sprites/` directories
- Placeholders are intentional fallbacks - app still functions

### Issue: High CPU usage
**Solutions:**
- Check sprite animation frame rates
- Reduce monitoring frequency in CPUUsageMonitor
- Ensure no animation loops running unnecessarily

### Issue: Pet doesn't follow Dock
**Solutions:**
- Dock position detection may be cached
- Force refresh: Menu → Reset Position  
- Check Console.app for Dock preference read errors

## 📋 Development Notes

### Code Style
- Swift 5.9 with modern concurrency
- `final class` and `private(set)` for encapsulation  
- `@MainActor` for UI-related code
- Comprehensive error handling and logging

### Performance Considerations
- Sprite loading is lazy and cached
- CPU monitoring uses background queues
- Window repositioning is throttled
- State machine prevents excessive transitions

### Security & Privacy
- No network access required
- File system access limited to dropped files
- Dock preferences read via public APIs
- No personal data collection

## 🏆 Future Enhancements

### Planned Features
- [ ] Multiple pet themes/skins
- [ ] Sound effects and voice
- [ ] More interactive gestures
- [ ] Notification reactions
- [ ] Customizable behaviors via settings panel
- [ ] iCloud sync for preferences

### Advanced Features
- [ ] Plugin architecture for custom behaviors
- [ ] AppleScript/Shortcuts integration
- [ ] Multiple pets on screen
- [ ] Pet-to-pet interactions
- [ ] Weather/calendar awareness

## 📄 License

MIT License - Feel free to modify and distribute!

## 🙏 Credits

Built with ❤️ using:
- **Swift & AppKit** - Native macOS development
- **SpriteKit** - Smooth 2D animations  
- **ServiceManagement** - Login item integration

---

**Enjoy your new desktop companion! 🐾**

*For issues or feature requests, please create an issue in the repository.*