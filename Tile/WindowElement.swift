//
//  WindowElement.swift
//  Tile
//
//  Created by yujuPonju on 2022/05/16.
//

import Cocoa
import ApplicationServices

class WindowElement {

    var AXUIElement: AXUIElement
    
    var appIndex: Int?
    var pid: pid_t
    var title: String
    var rect: CGRect
    var x: CGFloat
    var y: CGFloat
    var centerPoint: CGPoint
    var vector: CGPoint
    var width: CGFloat
    var height: CGFloat
    var top_left: CGPoint
    var top_right: CGPoint
    var bottom_left: CGPoint
    var bottom_right: CGPoint
    var focused: Bool = false
    var location: String?

    init? (windowAXUIElement: AXUIElement, screenElement: ScreenElement?, appIndex: Int?) {

        // check windowAXUIElement is vaild or not
        
              // check windowElement's role is windowRole
        guard let role = copyAttributeValue(element: windowAXUIElement, attribute: kAXRoleAttribute) as? String,
              role == kAXWindowRole,
              // check windowElement's subrole is standardWindowSubrole
              let subRole = copyAttributeValue(element: windowAXUIElement, attribute: kAXSubroleAttribute) as? String,
              subRole == kAXStandardWindowSubrole,
              // check windowElement is not fullScreen
              (copyAttributeValue(element: windowAXUIElement, attribute: "AXFullScreen") as? NSNumber)?.boolValue ?? false == false
        else { return nil }
        
        // set windowAXUIElement attribute
        self.AXUIElement = windowAXUIElement
        
        // set window application index
        if appIndex != nil { self.appIndex = appIndex }
        
        // set window pid_t
        var windowPid: pid_t = -1
        AXUIElementGetPid(windowAXUIElement, &windowPid)
        self.pid = windowPid
        
        // set window title
        guard let windowTitle = copyAttributeValue(element: windowAXUIElement, attribute: NSAccessibility.Attribute.title.rawValue) as? String else { return nil }
        self.title = windowTitle
        
        // set window position
        var windowPosition: CGPoint = CGPoint.zero
        AXValueGetValue(
            copyAttributeValue(element: windowAXUIElement, attribute: NSAccessibility.Attribute.position.rawValue) as! AXValue,
            AXValueType.cgPoint,
            &windowPosition
        )
        self.x = windowPosition.x
        self.y = windowPosition.y
        
        // set window size
        var windowSize: CGSize = CGSize.zero
        AXValueGetValue(
            copyAttributeValue(element: windowAXUIElement, attribute: NSAccessibility.Attribute.size.rawValue) as! AXValue,
            AXValueType.cgSize,
            &windowSize
        )
        self.width = windowSize.width
        self.height = windowSize.height
        
        // set window rect
        self.rect = CGRect(x: windowPosition.x, y: windowPosition.y, width: windowSize.width, height: windowSize.height)
        
        // set center point of window rect
        self.centerPoint = windowPosition.applying(CGAffineTransform(translationX: round(self.width/2.0), y: round(self.height/2.0)))
        
        // set vector from screen center to window center
        guard let screenCenterPosition = screenElement?.centerPoint else { return nil }
        self.vector = CGPoint(x: (self.centerPoint.x - screenCenterPosition.x), y: (self.centerPoint.y - screenCenterPosition.y))
        
        // set corner points of window rect
        self.top_left = CGPoint(x:self.rect.minX, y:self.rect.minY)
        self.top_right = CGPoint(x:self.rect.maxX, y:self.rect.minY)
        self.bottom_left = CGPoint(x:self.rect.minX, y:self.rect.maxY)
        self.bottom_right = CGPoint(x:self.rect.maxX, y:self.rect.maxY)
       
    }
    
    func isEqualWith(windowElement: WindowElement) -> Bool {
        if self.pid ==   windowElement.pid,
           self.title == windowElement.title,
           self.width == windowElement.width,
           self.height == windowElement.height,
           self.x == windowElement.x,
           self.y == windowElement.y
           { return true }

        return false
    }
    
    func move(_ newRect: CGRect, _ screenElement: ScreenElement?) {
        
        let intervalAmount = 40.0
        let intervalTime = 0.2 / intervalAmount

        var animationX = self.x
        var animationY = self.y
        var animationWidth = self.width
        var animationHeight = self.height
        
        let intervalX = (newRect.origin.x - self.x) / intervalAmount
        let intervalY = (newRect.origin.y - self.y) / intervalAmount
        let intervalWidth = (newRect.width - self.width) / intervalAmount
        let intervalHeight = (newRect.height - self.height) / intervalAmount
        
        var count = 0.0

        Timer.scheduledTimer(withTimeInterval: intervalTime,
                             repeats: true,
                             block: {(timer: Timer) in
            count += 1.0
            
            animationX += intervalX
            animationY += intervalY
            var origin = CGPoint(x: animationX, y: animationY)
            if let originValue = AXValueCreate(AXValueType.cgPoint, &origin) {
                guard self.setAttributeValue(attribute: kAXPositionAttribute, value: originValue) else {
                    timer.invalidate()
                    return
                }
            }
            
            animationWidth += intervalWidth
            animationHeight += intervalHeight
            
            var size = CGSize(width: animationWidth, height: animationHeight)
            if let sizeValue = AXValueCreate(AXValueType.cgSize, &size) {
                guard self.setAttributeValue(attribute: kAXSizeAttribute, value: sizeValue) else {
                    timer.invalidate()
                    return
                }
            }
            
            if count == intervalAmount {
                timer.invalidate()
                
                // update window element
                self.updateRect(screenElement: screenElement)
                
                // move mouse cursor
                if self.focused == true {
                    self.setMouseCursorOnWindow()
                }
            }
        })
    }
    
    @discardableResult
    func resize(_ newRect: CGRect, _ screenElement: ScreenElement?) -> Bool {
        
        // set new position of window
        var origin = newRect.origin
        if let originValue = AXValueCreate(AXValueType.cgPoint, &origin) {
            guard self.setAttributeValue(attribute: kAXPositionAttribute, value: originValue) else { return false}
        }
        
        // set new size of window
        var size = newRect.size
        if let sizeValue = AXValueCreate(AXValueType.cgSize, &size) {
            guard self.setAttributeValue(attribute: kAXSizeAttribute, value: sizeValue) else { return false}
        }
        
        // update rect
        self.updateRect(screenElement: screenElement)
       
        // return resizing is success or not
        if !size.equalTo(self.rect.size) {
            return false
        }
        
        return true
    }
    
    private func updateRect(screenElement: ScreenElement?) {

        // update window position
        var windowPosition: CGPoint = CGPoint.zero
        AXValueGetValue(
            copyAttributeValue(element: self.AXUIElement, attribute: NSAccessibility.Attribute.position.rawValue) as! AXValue,
            AXValueType.cgPoint,
            &windowPosition
        )
        self.x = windowPosition.x
        self.y = windowPosition.y
        
        // update window size
        var windowSize: CGSize = CGSize.zero
        AXValueGetValue(
            copyAttributeValue(element: self.AXUIElement, attribute: NSAccessibility.Attribute.size.rawValue) as! AXValue,
            AXValueType.cgSize,
            &windowSize
        )
        self.width = windowSize.width
        self.height = windowSize.height
        
        // update winow rect
        self.rect = CGRect(x: windowPosition.x, y: windowPosition.y, width: windowSize.width, height: windowSize.height)
        
        // update center point of window rect
        self.centerPoint = windowPosition.applying(CGAffineTransform(translationX: round(self.width/2.0), y: round(self.height/2.0)))
        
        // update vector from screen center to window center
        guard let screenCenterPosition = screenElement?.centerPoint else { return }
        self.vector = CGPoint(x: (self.centerPoint.x - screenCenterPosition.x), y: (self.centerPoint.y - screenCenterPosition.y))

        // update window corners point
        self.top_left = CGPoint(x:self.rect.minX, y:self.rect.minY)
        self.top_right = CGPoint(x:self.rect.maxX, y:self.rect.minY)
        self.bottom_left = CGPoint(x:self.rect.minX, y:self.rect.maxY)
        self.bottom_right = CGPoint(x:self.rect.maxX, y:self.rect.maxY)
    }
    
    func getCornersPointList() -> [CGPoint] {
        return [
            self.top_left, self.top_right, self.bottom_left, self.bottom_right
        ]
    }
    
    func setFocused(){
        NSWorkspace.shared.runningApplications[self.appIndex!].activate(options: .activateIgnoringOtherApps)
        AXUIElementSetAttributeValue(self.AXUIElement, kAXMainAttribute as CFString, kCFBooleanTrue as CFTypeRef)
        
        // set mouse-cursor on focused window
        self.setMouseCursorOnWindow()
    }
    
    func setMouseCursorOnWindow(){
        CGDisplayMoveCursorToPoint(0, self.centerPoint)
    }
    
    // MARK: private function
    private func setAttributeValue(attribute: String, value: CFTypeRef) -> Bool {
        let error = AXUIElementSetAttributeValue(self.AXUIElement, attribute as CFString, value)
        return error == .success
    }

}

class ScreenElement {
    
    var rect: CGRect
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    var centerPoint: CGPoint
    
    init? () {
        // set screen element's rect
        guard let mainScreen = NSScreen.main else { return nil}
        let visibleFrame = mainScreen.visibleFrame
        let offsetY = visibleFrame.height + visibleFrame.origin.y
        
        self.x = visibleFrame.origin.x
        self.y = mainScreen.frame.height - offsetY
        self.width = visibleFrame.width
        self.height = visibleFrame.height

        var screenRect = CGRect(x: self.x,
                                y: self.y,
                                width: self.width,
                                height: self.height)
        
        // Dock Left or Right
        if screenRect.width < mainScreen.frame.width {
            screenRect.size.width -= 1
            // Dock Left
            if 0 < screenRect.origin.x {
                screenRect.origin.x += 1
            }
        }
        self.rect = screenRect
        
        // set center point of screen
        self.centerPoint = self.rect.origin.applying(
            CGAffineTransform(translationX: round(rect.width/2.0), y: round(rect.height/2.0))
        )
    }
    
}

func copyAttributeValue(element: AXUIElement, attribute: String) -> CFTypeRef? {
    var ref: CFTypeRef? = nil
    let error = AXUIElementCopyAttributeValue(element, attribute as CFString, &ref)
    if error == .success { return ref }
    return .none
}
