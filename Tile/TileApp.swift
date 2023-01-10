//
//  TileApp.swift
//  Tile
//
//  Created by muuunman on 2023/01/09.
//

import SwiftUI

@main
struct TileApp: App {
#if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
#endif
    
    @StateObject private var keyboardShortcutsState = KeyboardShortcutsState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover?

    func applicationDidFinishLaunching(_ notification: Notification) {
        
        // check the accessibilitiy is unlocked
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        if !accessEnabled {
            print("Access Not Enabled")
        }
        
        // close Content view
        NSApp.setActivationPolicy(.accessory)
        NSApp.windows.forEach{ $0.close() }
        
        // set popup-menu
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let button = statusItem.button!
        //button.image = NSImage(systemSymbolName: "leaf", accessibilityDescription: nil)
        button.image = NSImage(named: NSImage.Name("StatusbarIcon"))
        button.action = #selector(showPopover)
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
 
    @objc func showPopover(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == NSEvent.EventType.rightMouseUp {
            let menu = NSMenu()

            menu.addItem(
                withTitle: NSLocalizedString("Quit", comment: "Quit app"),
                action: #selector(terminate),
                keyEquivalent: ""
            )
            statusItem?.popUpMenu(menu)
            return
        }

        if popover == nil {
            let popover = NSPopover()
            popover.behavior = .transient
            popover.animates = false
            //popover.contentViewController = NSHostingController(rootView: ContentView())
            popover.contentViewController = NSHostingController(rootView: KeyboardShortcutsScreen())

            self.popover = popover
        }
        popover?.show(relativeTo: sender.bounds, of: sender, preferredEdge: NSRectEdge.maxY)
        popover?.contentViewController?.view.window?.makeKey()
    }
    
    @objc func terminate() {
        NSApp.terminate(self)
    }
 
}
#endif
