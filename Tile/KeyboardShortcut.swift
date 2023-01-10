import SwiftUI
import KeyboardShortcuts

// MARK: Register Shortcuts
extension KeyboardShortcuts.Name {
    // shortcut for tile windows
    static let tileWindows = Self("tileWindows")
    static let tileOneWindow = Self("tileOneWindow")
    
    // shortcut for switch focus on window
    static let switchFocusToNextClockwiseWindow = Self("switchFocusToNextClockwiseWindow")
    static let switchFocusToNextAnticlockwiseWindow = Self("switchFocusToNextAnticlockwiseWindow")
    
    // replace windows
    static let replaceWithNextClockwiseWindow = Self("replaceWithNextClockwiseWindow")
    static let replaceWithNextAnticlockwiseWindow = Self("replaceWithNextAnticlockwiseWindow")
    
    // resize windows
    static let resizeOnLeftside = Self("resizeOnLeftside")
    static let resizeOnRightside = Self("resizeOnRightside")
    static let resizeOnUpside = Self("resizeOnUpside")
    static let resizeOnDownside = Self("resizeOnDownside")
    
}

// MARK: Setting window

struct TileWindowsView: View {
    var body: some View {
        Form {
            // keyboard shortcut recorder for tiling windows
            KeyboardShortcuts.Recorder("tile windows", name: .tileWindows)
            KeyboardShortcuts.Recorder("tile one window", name: .tileOneWindow)
        }
        .padding()
    }
}

struct SwitchFocusedWindowView: View {
    var body: some View {
        Form {
            // keyboard shortcut recorder for switching focus on window
            KeyboardShortcuts.Recorder("switch focus clockwise", name: .switchFocusToNextClockwiseWindow)
            KeyboardShortcuts.Recorder("switch focus anti-clockwise", name: .switchFocusToNextAnticlockwiseWindow)
        }
        .padding()
    }
}

struct ReplaceWindowsView: View {
    var body: some View {
        Form {
            // keyboard shortcut recorder for replacing windows
            KeyboardShortcuts.Recorder("replace with clockwise", name: .replaceWithNextClockwiseWindow)
            
            KeyboardShortcuts.Recorder("replace with anti-clockwise", name: .replaceWithNextAnticlockwiseWindow)
        }
        .padding()
    }
}

struct ResizeWindowsView: View {
    var body: some View {
        Form {
            // keyboard shortcut recorder for resizing windows
            KeyboardShortcuts.Recorder("resize up side of window", name: .resizeOnUpside)
            
            KeyboardShortcuts.Recorder("resize down side of window", name: .resizeOnDownside)
            
            KeyboardShortcuts.Recorder("resize left side of window", name: .resizeOnLeftside)
            
            KeyboardShortcuts.Recorder("resize right side of window", name: .resizeOnRightside)
        }
        .padding()
        
    }
}

struct KeyboardShortcutsScreen: View {
    var body: some View {
        VStack {
            
            TileWindowsView()
            Divider()
            SwitchFocusedWindowView()
            Divider()
            ReplaceWindowsView()
            Divider()
            ResizeWindowsView()
        }
        .frame(width: 350)
        .padding()
    }
}
struct KeyboardShortcutView_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardShortcutsScreen()
    }
}

// MARK: state
@MainActor
final class KeyboardShortcutsState: ObservableObject {
    private var windowManager: WindowManager!
    
    init() {
        self.windowManager = WindowManager()
        
        // activate shortcut for tiling windows
        KeyboardShortcuts.onKeyUp(for: .tileWindows, action: {() -> Void in self.windowManager.tileWindows()})
        KeyboardShortcuts.onKeyUp(for: .tileOneWindow, action: {() -> Void in self.windowManager.tileOneWindow()})

        // activate shortcut for switching focused window
        KeyboardShortcuts.onKeyUp(for: .switchFocusToNextClockwiseWindow, action: {() -> Void in self.windowManager.switchWindowFocus(clockWise: true)})
        
        KeyboardShortcuts.onKeyUp(for: .switchFocusToNextAnticlockwiseWindow, action: {() -> Void in self.windowManager.switchWindowFocus(clockWise: false)})
        
        // activate shortcut for replacing windows
        KeyboardShortcuts.onKeyUp(for: .replaceWithNextClockwiseWindow, action: {() -> Void in self.windowManager.replaceWindows(clockWise: true)})
        KeyboardShortcuts.onKeyUp(for: .replaceWithNextAnticlockwiseWindow, action: {() -> Void in self.windowManager.replaceWindows(clockWise: false)})
        
        // activate shortcut for resizing windows
        KeyboardShortcuts.onKeyUp(for: .resizeOnUpside, action: {() -> Void in self.windowManager.resizeWindow(direction: "up arrow")})
        KeyboardShortcuts.onKeyUp(for: .resizeOnDownside, action: {() -> Void in self.windowManager.resizeWindow(direction: "down arrow")})
        KeyboardShortcuts.onKeyUp(for: .resizeOnLeftside, action: {() -> Void in self.windowManager.resizeWindow(direction: "left arrow")})
        KeyboardShortcuts.onKeyUp(for: .resizeOnRightside, action: {() -> Void in self.windowManager.resizeWindow(direction: "right arrow")})
    }
}
