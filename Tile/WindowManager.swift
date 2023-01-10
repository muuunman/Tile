//
//  WindowManager.swift
//  Tile
//
//  Created by muuunman on 2022/05/13.
//

import Cocoa
import ApplicationServices
import Foundation

class WindowManager {
    
    // window & screen parameters
    private var focusedWindowElement: WindowElement?
    private var theOthersWindowElements: [WindowElement]?
    private var screenElement: ScreenElement?
    private var windowsTiledOnScreen: Bool = false
    
    // parameters for resizing window
    private let resizeDimension = 20.0
    
    init() {
        for screen in NSScreen.screens {
            // get screen id which has mouse cursor on
            let screenDescription = screen.deviceDescription
            print("_____ screen description")
            print(screenDescription[NSDeviceDescriptionKey("NSScreenNumber")]!)
            print(screenDescription[NSDeviceDescriptionKey("NSDeviceResolution")]!)
            print(screenDescription[NSDeviceDescriptionKey("NSDeviceIsScreen")] as! String == "YES")
            print(screenDescription[NSDeviceDescriptionKey("NSDeviceSize")]!)
            for (key, _) in screenDescription {
                print(key.rawValue )
            }
            print("--------")
            print(NSEvent.mouseLocation)
            print(NSMouseInRect(NSEvent.mouseLocation, screen.frame, false))
            print("========")
        }
    }

    // MARK: move windows
    func tileWindows() {
        // windowElements & screenElement
        self.updateWindowElements()

        // move windowElements by window amount
        switch self.theOthersWindowElements?.count {
        case 0:
            self.moveOneWindow()

        case 1:
            self.moveTwoWindows()

        case 2:
            self.moveThreeWindows()

        case 3:
            self.moveFourWindows()

        default:
            print("other")
        }

    }
    
    func tileOneWindow() {
        
        self.updateFocusedWindowElement()
        self.moveOneWindow()
    }

    private func moveOneWindow(){
    
        guard let focusedWindowElement: WindowElement = self.focusedWindowElement,
              let screenElement: ScreenElement = self.screenElement
        else { return }

        // when focused window is not located on center of the screen
        guard let centeredWindowElement = self.getCenteredOnScreenElement(windowElement: focusedWindowElement) else { return }
        if !focusedWindowElement.rect.equalTo(centeredWindowElement) {
            // set focused window on center
            focusedWindowElement.move(centeredWindowElement, self.screenElement)
            return
        }

        // when focused window is full in screen
        if screenElement.rect.equalTo(focusedWindowElement.rect) {
            // then set it to small size on center
            let newRect = focusedWindowElement.rect.insetBy(dx: round(screenElement.width/4), dy: round(screenElement.height/4))
            
            focusedWindowElement.resize(newRect, self.screenElement)
            return
        }

        guard let screenElement = self.screenElement else { return }
        // when focused window is full in screen height
        if focusedWindowElement.y == screenElement.rect.minY
            && focusedWindowElement.height == screenElement.height
        {
            // then set window to full in screen
            focusedWindowElement.resize(screenElement.rect, self.screenElement)
            return
        }

        // set other window to full in height
        focusedWindowElement.resize(CGRect(x: focusedWindowElement.x, y: screenElement.rect.minY, width: focusedWindowElement.width, height: screenElement.height), self.screenElement)

    }
    
    private func moveTwoWindows() {
        guard let focusedWindowElement: WindowElement = self.focusedWindowElement,
              let anotherWindowElement: WindowElement = self.theOthersWindowElements?[0],
              let screenElement: ScreenElement = self.screenElement
        else { return }
        
        // divide window to two rects
        let dividedWindow = screenElement.rect.divided(atDistance: round(screenElement.width * 3 / 5), from: CGRectEdge.minXEdge)
        
        // move windowElement
        focusedWindowElement.move(dividedWindow.slice, self.screenElement)
        anotherWindowElement.move(dividedWindow.remainder, self.screenElement)
        
    }
    
    private func moveThreeWindows() {
 
        guard let focusedWindowElement: WindowElement = self.focusedWindowElement,
              let theOthersWindowElements: [WindowElement] = self.theOthersWindowElements,
              let screenElement: ScreenElement = self.screenElement
        else { return }
        
        // divide window to three rects
        let (windowRect1, windowRect2) = screenElement.rect.divided(atDistance: round(screenElement.width/2), from: CGRectEdge.minXEdge)
        let (windowRect2_1, windowRect2_2) = windowRect2.divided(atDistance: round(windowRect2.height/2), from: CGRectEdge.minYEdge)
    
        // set new rect to all windowElements
        focusedWindowElement.move(windowRect1, self.screenElement)
        theOthersWindowElements[0].move(windowRect2_1, self.screenElement)
        theOthersWindowElements[1].move(windowRect2_2, self.screenElement)

    }
    
    private func moveFourWindows() {
        
        guard let focusedWindowElement: WindowElement = self.focusedWindowElement,
              let theOthersWindowElements: [WindowElement] = self.theOthersWindowElements,
              let screenElement: ScreenElement = self.screenElement
        else { return }
        
        // divide window to four rects
        let (windowRect1, windowRect2) = screenElement.rect.divided(atDistance: round(screenElement.width/2), from: CGRectEdge.minXEdge)
        let (windowRect1_1, windowRect1_2) = windowRect1.divided(atDistance: round(windowRect1.height/2), from: CGRectEdge.minYEdge)
        let (windowRect2_1, windowRect2_2) = windowRect2.divided(atDistance: round(windowRect2.height/2), from: CGRectEdge.minYEdge)
        
        // move all windowElements with windowRect
        focusedWindowElement.move(windowRect1_1, self.screenElement)
        theOthersWindowElements[0].move(windowRect1_2, self.screenElement)
        theOthersWindowElements[1].move(windowRect2_1, self.screenElement)
        theOthersWindowElements[2].move(windowRect2_2, self.screenElement)
        
    }

    // MARK: resize window
    func resizeWindow(direction: String) {
        // windowElements & screenElement
        self.updateWindowElements()
        
        // resize window element by windowElements amuont
        switch self.theOthersWindowElements?.count {
        case 0:
            self.resizeOneWindow(direction)

        case 1:
            self.resizeTwoWindows(direction)
            
        case 2:
            self.resizeThreeWindows(direction)

        case 3:
            self.resizeFourWindows(direction)
        default:
            print("other")
        }
    }

    private func resizeOneWindow(_ direction: String){

        guard let focusedWindowElement: WindowElement = self.focusedWindowElement,
              let screenElement: ScreenElement = self.screenElement
        else { return }
        
        var newRect = screenElement.rect
        
        switch direction {
            
        case "left arrow":
            newRect = focusedWindowElement.rect.insetBy(dx: self.resizeDimension, dy: 0.0)
            
        case "right arrow":
            newRect = focusedWindowElement.rect.insetBy(dx: -self.resizeDimension, dy: 0.0)
            if newRect.minX <= screenElement.rect.minX {
                newRect = CGRect(origin: CGPoint(x: screenElement.rect.minX, y: newRect.minY), size: newRect.size)
            }
            
        case "up arrow":
            newRect = focusedWindowElement.rect.insetBy(dx: 0.0, dy: -self.resizeDimension)
            if newRect.minY <= screenElement.rect.minY {
                newRect = CGRect(origin: CGPoint(x: newRect.minX, y: screenElement.rect.minY), size: newRect.size)
            }
        
        case "down arrow":
            newRect = focusedWindowElement.rect.insetBy(dx: 0.0, dy: self.resizeDimension)

        default: return
        }
        
        // resize focused window
        let oldWindowRect = focusedWindowElement.rect
        
        // if resizing focused window is successed, then reutrn
        if focusedWindowElement.resize(newRect, self.screenElement) { return }
        
        // if failed in resizing, then restore to privious size of focused window
        focusedWindowElement.resize(oldWindowRect, self.screenElement)

    }
    
    private func resizeTwoWindows(_ direction: String) {
       
        // if windows are not tiled on screen, then call resizeOneWindow
        if self.windowsTiledOnScreen == false {
            self.resizeOneWindow(direction)
            return
        }
        
        guard let focusedWindowElement: WindowElement = self.focusedWindowElement,
              let anotherWindowElement: WindowElement = self.theOthersWindowElements?[0],
              let screenElement: ScreenElement = self.screenElement
        else { return }
        
        // set all windows located to dictionary
        var windowElementLocationDict: [String: WindowElement] = [:]
        
        for windowElement in [focusedWindowElement] + [anotherWindowElement] {
            var windowLocation: String
            if windowElement.rect.origin.equalTo(screenElement.rect.origin) {
                windowLocation = "left"
            } else {
                windowLocation = "right"
            }
            windowElementLocationDict.updateValue(windowElement, forKey: windowLocation)
            windowElement.location = windowLocation
        }
        
        // set new focused window size
        var newFocusedWindow_width: CGFloat = focusedWindowElement.width
        
        switch focusedWindowElement.location {
        case "left":
            newFocusedWindow_width += direction == "right arrow" ? self.resizeDimension : -self.resizeDimension
        case "right":
            newFocusedWindow_width += direction == "right arrow" ? -self.resizeDimension : self.resizeDimension
        default: return
        }
        
        // set windows rect
        let leftWindowRect: CGRect
        let rightWindowRect: CGRect
        
        switch focusedWindowElement.location {
        case "left":
            (leftWindowRect, rightWindowRect) = screenElement.rect.divided(atDistance: newFocusedWindow_width, from: CGRectEdge.minXEdge)
        case "right":
            (rightWindowRect, leftWindowRect) = screenElement.rect.divided(atDistance: newFocusedWindow_width, from: CGRectEdge.maxXEdge)
        default: return
        }
        
        // resize window element rects
        let oldLeftWindowRect = windowElementLocationDict["left"]!.rect
        let oldRightWindowRect = windowElementLocationDict["right"]!.rect
        
        // if resizing all windows are successed, then return
        if windowElementLocationDict["left"]!.resize(leftWindowRect, self.screenElement),
           windowElementLocationDict["right"]!.resize(rightWindowRect, self.screenElement)
        { return }
      
        // if some window is failed in resizing, then restore size of all windows
        windowElementLocationDict["left"]!.resize(oldLeftWindowRect, self.screenElement)
        windowElementLocationDict["right"]!.resize(oldRightWindowRect, self.screenElement)
        
    }

    private func resizeThreeWindows(_ direction: String) {
        
        // if windows are not tiled on screen, then call resizeOneWindow
        if self.windowsTiledOnScreen == false {
            self.resizeOneWindow(direction)
            return
        }
        
        guard let focusedWindowElement: WindowElement = self.focusedWindowElement,
              let theOthersWindowElements: [WindowElement] = self.theOthersWindowElements,
              let screenElement: ScreenElement = self.screenElement
        else { return }
        
        // set all windows location to dictionary
        var windowElementLocationDict: [String: WindowElement] = [:]
        
        for windowElement in [focusedWindowElement] + theOthersWindowElements {
            var windowLocation: String = ""
            if windowElement.rect.origin.equalTo(screenElement.rect.origin) {
                windowLocation = "left"
            } else if windowElement.top_right.equalTo(CGPoint(x: screenElement.rect.maxX, y: screenElement.rect.minY)) {
                windowLocation = "top-right"
            } else if windowElement.bottom_right.equalTo(CGPoint(x: screenElement.rect.maxX, y: screenElement.rect.maxY)) {
                windowLocation = "bottom-right"
            }
            windowElementLocationDict.updateValue(windowElement, forKey: windowLocation)
            windowElement.location = windowLocation
        }
        
        // set new focused window size
        var newFocusedWindow_width: CGFloat = focusedWindowElement.width
        var newFocusedWindow_height: CGFloat = focusedWindowElement.height
        
        switch focusedWindowElement.location {
        case "left":
            switch direction {
            case "left arrow":
                newFocusedWindow_width -= self.resizeDimension
            case "right arrow":
                newFocusedWindow_width += self.resizeDimension
            default: return
            }
            
        case "top-right":
            switch direction {
            case "left arrow":
                newFocusedWindow_width += self.resizeDimension
            case "right arrow":
                newFocusedWindow_width -= self.resizeDimension
            case "up arrow":
                newFocusedWindow_height -= self.resizeDimension
            case "down arrow":
                newFocusedWindow_height += self.resizeDimension
            default: return
            }
            
        case "bottom-right":
            switch direction {
        case "left arrow":
            newFocusedWindow_width += self.resizeDimension
        case "right arrow":
            newFocusedWindow_width -= self.resizeDimension
        case "up arrow":
            newFocusedWindow_height += self.resizeDimension
        case "down arrow":
            newFocusedWindow_height -= self.resizeDimension
        default: return
        }
        
        default: return
        }
        
        // set windows rect
        var leftWindowRect: CGRect
        var rightWindowRect: CGRect
        var topRightWindowRect: CGRect
        var bottomRightWindowRect: CGRect
        
        switch focusedWindowElement.location {
        case "left":
            (leftWindowRect, rightWindowRect) = screenElement.rect.divided(atDistance: newFocusedWindow_width, from: CGRectEdge.minXEdge)
            (topRightWindowRect, bottomRightWindowRect) = rightWindowRect.divided(atDistance: windowElementLocationDict["top-right"]!.height, from: CGRectEdge.minYEdge)

        case "top-right":
            (rightWindowRect, leftWindowRect) = screenElement.rect.divided(atDistance: newFocusedWindow_width, from: CGRectEdge.maxXEdge)
            (topRightWindowRect, bottomRightWindowRect) = rightWindowRect.divided(atDistance: newFocusedWindow_height, from: CGRectEdge.minYEdge)
        case "bottom-right":
            (rightWindowRect, leftWindowRect) = screenElement.rect.divided(atDistance: newFocusedWindow_width, from: CGRectEdge.maxXEdge)
            (bottomRightWindowRect, topRightWindowRect) = rightWindowRect.divided(atDistance: newFocusedWindow_height, from: CGRectEdge.maxYEdge)
        default: return
        }
        
        // resize window element rects
        let oldLeftWindowRect = windowElementLocationDict["left"]!.rect
        let oldTopRightWindowRect = windowElementLocationDict["top-right"]!.rect
        let oldBottomRightWindowRect = windowElementLocationDict["bottom-right"]!.rect
        
        // if resizing all windows are successed, then return
        if windowElementLocationDict["left"]!.resize(leftWindowRect, self.screenElement),
           windowElementLocationDict["top-right"]!.resize(topRightWindowRect, self.screenElement),
           windowElementLocationDict["bottom-right"]!.resize(bottomRightWindowRect, self.screenElement)
        { return }
        
        // if some window is failed in resizing, then restore size of all windows
        windowElementLocationDict["left"]!.resize(oldLeftWindowRect, self.screenElement)
        windowElementLocationDict["top-right"]!.resize(oldTopRightWindowRect, self.screenElement)
        windowElementLocationDict["bottom-right"]!.resize(oldBottomRightWindowRect, self.screenElement)

    }
    
    private func resizeFourWindows(_ direction: String) {
        
        // if windows are not tiled on screen, then call resizeOneWindow
        if self.windowsTiledOnScreen == false {
            self.resizeOneWindow(direction)
            return
        }
        
        guard let focusedWindowElement: WindowElement = self.focusedWindowElement,
              let theOthersWindowElements: [WindowElement] = self.theOthersWindowElements,
              let screenElement: ScreenElement = self.screenElement
        else { return }
        
        // set all windows location to dictionary
        var windowElementLocationDict: [String: WindowElement] = [:]

        for windowElement in [focusedWindowElement]+theOthersWindowElements {
            var windowLocation: String = ""
            if windowElement.top_left.equalTo(screenElement.rect.origin) {
                windowLocation = "top-left"
            } else if windowElement.bottom_left.equalTo(CGPoint(x: screenElement.rect.minX, y: screenElement.rect.maxY)) {
                windowLocation = "bottom-left"
            } else if windowElement.top_right.equalTo(CGPoint(x: screenElement.rect.maxX, y: screenElement.rect.minY)) {
                windowLocation = "top-right"
            } else if windowElement.bottom_right.equalTo(CGPoint(x: screenElement.rect.maxX, y: screenElement.rect.maxY)) {
                windowLocation = "bottom-right"
            }
            windowElementLocationDict.updateValue(windowElement, forKey: windowLocation)
            windowElement.location = windowLocation
        }
                
        // set new focused tindow size
        var newFocusedWindow_width: CGFloat = focusedWindowElement.width
        var newFocusedWindow_height: CGFloat = focusedWindowElement.height
        
        switch focusedWindowElement.location {
        case "top-left":
            switch direction {
            case "left arrow":
                newFocusedWindow_width -= self.resizeDimension
            case "right arrow":
                newFocusedWindow_width += self.resizeDimension
            case "up arrow":
                newFocusedWindow_height -= self.resizeDimension
            case "down arrow":
                newFocusedWindow_height += self.resizeDimension
            default: return
            }
        case "bottom-left":
            switch direction {
            case "left arrow":
                newFocusedWindow_width -= self.resizeDimension
            case "right arrow":
                newFocusedWindow_width += self.resizeDimension
            case "up arrow":
                newFocusedWindow_height += self.resizeDimension
            case "down arrow":
                newFocusedWindow_height -= self.resizeDimension
            default: return
            }
        case "top-right":
            switch direction {
            case "left arrow":
                newFocusedWindow_width += self.resizeDimension
            case "right arrow":
                newFocusedWindow_width -= self.resizeDimension
            case "up arrow":
                newFocusedWindow_height -= self.resizeDimension
            case "down arrow":
                newFocusedWindow_height += self.resizeDimension
            default: return
            }
        case "bottom-right":
            switch direction {
            case "left arrow":
                newFocusedWindow_width += self.resizeDimension
            case "right arrow":
                newFocusedWindow_width -= self.resizeDimension
            case "up arrow":
                newFocusedWindow_height += self.resizeDimension
            case "down arrow":
                newFocusedWindow_height -= self.resizeDimension
            default: return
            }
        default:  return
        }
        
        // set windows rect
        var leftWindowRect: CGRect
        var topLeftWindowRect: CGRect
        var bottomLeftWindowRect: CGRect
        var rightWindowRect: CGRect
        var topRightWindowRect: CGRect
        var bottomRightWindowRect: CGRect
        
        switch focusedWindowElement.location {
        case "top-left":
            (leftWindowRect, rightWindowRect) = screenElement.rect.divided(atDistance: newFocusedWindow_width, from: CGRectEdge.minXEdge)
            (topLeftWindowRect, bottomLeftWindowRect) = leftWindowRect.divided(atDistance: newFocusedWindow_height, from: CGRectEdge.minYEdge)
            (topRightWindowRect, bottomRightWindowRect) = rightWindowRect.divided(atDistance: newFocusedWindow_height, from: CGRectEdge.minYEdge)
            
        case "bottom-left":
            (leftWindowRect, rightWindowRect) = screenElement.rect.divided(atDistance: newFocusedWindow_width, from: CGRectEdge.minXEdge)
            (bottomLeftWindowRect, topLeftWindowRect) = leftWindowRect.divided(atDistance: newFocusedWindow_height, from: CGRectEdge.maxYEdge)
            (bottomRightWindowRect, topRightWindowRect) = rightWindowRect.divided(atDistance: newFocusedWindow_height, from: CGRectEdge.maxYEdge)
            
        case "top-right":
            (rightWindowRect, leftWindowRect) = screenElement.rect.divided(atDistance: newFocusedWindow_width, from: CGRectEdge.maxXEdge)
            (topRightWindowRect, bottomRightWindowRect) = rightWindowRect.divided(atDistance: newFocusedWindow_height, from: CGRectEdge.minYEdge)
            (topLeftWindowRect, bottomLeftWindowRect) = leftWindowRect.divided(atDistance: newFocusedWindow_height, from: CGRectEdge.minYEdge)
           
            case "bottom-right":
            (rightWindowRect, leftWindowRect) = screenElement.rect.divided(atDistance: newFocusedWindow_width, from: CGRectEdge.maxXEdge)
            (bottomLeftWindowRect, topLeftWindowRect) = leftWindowRect.divided(atDistance: newFocusedWindow_height, from: CGRectEdge.maxYEdge)
            (bottomRightWindowRect, topRightWindowRect) = rightWindowRect.divided(atDistance: newFocusedWindow_height, from: CGRectEdge.maxYEdge)
            
        default: return
        }
        
        // resize window element rects
        let oldTopLeftWindowRect = windowElementLocationDict["top-left"]!.rect
        let oldBottomLeftWindowRect = windowElementLocationDict["bottom-left"]!.rect
        let oldTopRightWindowRect = windowElementLocationDict["top-right"]!.rect
        let oldBottomRightWindowRect = windowElementLocationDict["bottom-right"]!.rect
        
        // if resizing all windows are successed, then return
        if windowElementLocationDict["top-left"]!.resize(topLeftWindowRect, self.screenElement),
           windowElementLocationDict["bottom-left"]!.resize(bottomLeftWindowRect, self.screenElement),
           windowElementLocationDict["top-right"]!.resize(topRightWindowRect, self.screenElement),
           windowElementLocationDict["bottom-right"]!.resize(bottomRightWindowRect, self.screenElement)
        { return }
        
        // if some window is failed in resizing, then restore size of all windows
        windowElementLocationDict["top-left"]!.resize(oldTopLeftWindowRect, self.screenElement)
        windowElementLocationDict["bottom-left"]!.resize(oldBottomLeftWindowRect, self.screenElement)
        windowElementLocationDict["top-right"]!.resize(oldTopRightWindowRect, self.screenElement)
        windowElementLocationDict["bottom-right"]!.resize(oldBottomRightWindowRect, self.screenElement)
        
    }

    // MARK: switch window focus
    func switchWindowFocus(clockWise: Bool) {
        
        // get nearest windowElement
        guard let nearestWindowElement = self.getNearestWindowElement(clockWise: clockWise) else { return }
        
        // set focus on nearest windowElement
        nearestWindowElement.setFocused()
        
      
    }
    
    // MARK: replace window with next one
    func replaceWindows(clockWise: Bool) {
         
        // get nearest windowElement and focused windowElement
        guard let nearestWindowElement = self.getNearestWindowElement(clockWise: clockWise),
              let focusedWindowElement = self.focusedWindowElement
        else { return }
        
        // replace rect of focusedWindow with nearestWindow rect
        let focusedWindowRect = focusedWindowElement.rect
        let nearestWindowRect = nearestWindowElement.rect
        
        focusedWindowElement.move(nearestWindowRect, self.screenElement)
        nearestWindowElement.move(focusedWindowRect, self.screenElement)
        
    }
    
    // MARK: fundation function
    
    private func updateFocusedWindowElement() {
        // update focused windowElement
        guard let activeApp = NSWorkspace.shared.runningApplications.first(where: { $0.isActive }),
              let focusedWindowAXUIElement = self.copyAttributeValue(AXUIElementCreateApplication(activeApp.processIdentifier), attribute: kAXFocusedWindowAttribute),
              let focusedWindowElement = WindowElement(windowAXUIElement: focusedWindowAXUIElement as! AXUIElement, screenElement: self.screenElement, appIndex: nil)
        else { return }
        
        focusedWindowElement.focused = true
        self.focusedWindowElement = focusedWindowElement
    }
    
    private func updateWindowElements() {

        // update screenElement
        self.screenElement = ScreenElement()
        if self.screenElement == nil { return }
        
        // upadte focusedWindowElement
        self.updateFocusedWindowElement()

        // update windowElements which are visible and vaild
        var theOthersWindowElements : [WindowElement] = []
        for (idx, app) in NSWorkspace.shared.runningApplications.enumerated() {

            if ["QLPreviewGenerationExtension (Finder)", "System Preferences", "Finder"].contains(app.localizedName) { continue }
            
            guard let windowAXUIElements = self.copyAttributeValue(AXUIElementCreateApplication(app.processIdentifier), attribute: NSAccessibility.Attribute.windows.rawValue) as? [AXUIElement] else { continue }
            
            for windowAXUIElement in windowAXUIElements {
                guard let windowElement = WindowElement(windowAXUIElement: windowAXUIElement, screenElement: self.screenElement, appIndex: idx) else { continue }
                if app.isActive {
                    if windowElement.isEqualWith(windowElement: self.focusedWindowElement!) { continue }
                }
                theOthersWindowElements.append(windowElement)
            }
        }
        self.theOthersWindowElements = theOthersWindowElements
        
        // update whether windows are on screen
        self.windowsTiledOnScreen = self.isWindowsTiledOnScreen()
        
    }
    
    private func isWindowsTiledOnScreen() -> Bool {
        guard let focusedWindowElement: WindowElement = self.focusedWindowElement,
              let theOthersWindowElements: [WindowElement] = self.theOthersWindowElements,
              let screenElement: ScreenElement = self.screenElement
        else { return false }
        let allWindowElements: [WindowElement] = [focusedWindowElement] + theOthersWindowElements
        
        // wheter windowElements are facing each other or not
        for i in 0..<allWindowElements.count {
            for j in (i+1)..<allWindowElements.count {
                let windowElement1 = allWindowElements[i]
                let windowElement2 = allWindowElements[j]
                let intersectionRect = windowElement1.rect.intersection(windowElement2.rect)
                
                // if two windowElements are not facing at all, then return notTlied(false)
                guard intersectionRect.isEmpty==true && intersectionRect.isInfinite==false && intersectionRect.isNull==false else { return false }
            }
        }
        
        // whether union of all windowElements is
        var unionedRect: CGRect = focusedWindowElement.rect
        for windowElement in theOthersWindowElements {
            unionedRect = unionedRect.union(windowElement.rect)
        }
        guard screenElement.rect.equalTo(unionedRect) else { return false }
        
        // whether screen corners are same with any one of windowElement's corner
        let screenCornersCoordinate =  [
            CGPoint(x: screenElement.rect.minX, y: screenElement.rect.minY),
            CGPoint(x: screenElement.rect.maxX, y: screenElement.rect.minY),
            CGPoint(x: screenElement.rect.maxX, y: screenElement.rect.maxY),
            CGPoint(x: screenElement.rect.minX, y: screenElement.rect.maxY)
        ]
        
        for screenCornerCoordinate in screenCornersCoordinate {
            var isScreenCorner = false
            
            for windowElement in allWindowElements {
                for windowCornerCoordinate in windowElement.getCornersPointList() {
                    if screenCornerCoordinate.equalTo(windowCornerCoordinate) {
                        isScreenCorner = true
                        break
                    }
                }
            }
            if isScreenCorner == false { return false }
        }
        
        return true
    }
    
    private func getCenteredOnScreenElement(windowElement: WindowElement) -> CGRect? {

        guard let screenElement: ScreenElement = self.screenElement else { return nil }
        let centeredWindowX = screenElement.rect.minX + round((screenElement.width - windowElement.width) / 2)
        let centeredWindowY = screenElement.rect.minY + round((screenElement.height - windowElement.height) / 2)
        
        return windowElement.rect.offsetBy(dx: (centeredWindowX-windowElement.x), dy: (centeredWindowY-windowElement.y))
        
    }
    
    private func getNearestWindowElement(clockWise: Bool) -> WindowElement? {
        self.updateWindowElements()
        
        guard let focusedWindowElement: WindowElement = self.focusedWindowElement,
              let theOthersWindowElements: [WindowElement] = self.theOthersWindowElements
        else { return nil}
        
        if theOthersWindowElements.count == 0 { return nil }
        
        // find windowElement which is nearest from focused window by angle
        let windowsAngleList = theOthersWindowElements.map { (windowElement: WindowElement) -> CGFloat in
            return self.getDegree(anchor: focusedWindowElement.vector, active: windowElement.vector, clockWise: clockWise)
        }
        
        guard let minAngleIndex = windowsAngleList.enumerated().min(by: {(a,b) in a.element < b.element})?.offset
        else { return nil }
        
        return theOthersWindowElements[minAngleIndex]
        
    }
    
    private func copyAttributeValue(_ element: AXUIElement, attribute: String) -> CFTypeRef? {
        var ref: CFTypeRef? = nil
        let error = AXUIElementCopyAttributeValue(element, attribute as CFString, &ref)
        if error == .success {
            return ref
        }
        return .none
    }

    private func setAttributeValue(_ element: AXUIElement, attribute: String, value: CFTypeRef) -> Bool {
        let error = AXUIElementSetAttributeValue(element, attribute as CFString, value)
        return error == .success
    }
    
    private func getDegree(anchor anchorVector: CGPoint, active activeVector: CGPoint, clockWise: Bool) -> CGFloat{
        
        // set arcCos of verctorA and vectorB
        let cos = (anchorVector.x * activeVector.x + anchorVector.y * activeVector.y) / (sqrt(pow(anchorVector.x, 2.0)+pow(anchorVector.y, 2.0)) * sqrt(pow(activeVector.x, 2.0) + pow(activeVector.y, 2.0)))
        let arcCos = acos(cos)
        let tempDegree = arcCos * (180.0 / Double.pi)
        
        // set cross product of vectorA and vectorB
        let crossProduct = anchorVector.x * activeVector.y - anchorVector.y * activeVector.x
        
        // set degree
        var degree: CGFloat = tempDegree
        if clockWise {
            if crossProduct < 0.0 {
                degree = 360.0 - degree
            }
        } else {
            if crossProduct > 0.0 {
                degree = 360.0 - degree
            }
        }
    
        return degree
    }
    
}

