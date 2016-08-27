//
//  WorldMapView.swift
//  World Map
//
//  Created by Jože Ws on 8/26/16.
//  Copyright © 2016 JožeWs. All rights reserved.
//

//x: 1887211.026663, y: 6207065.496951 // coordinate 0 of Austria

import UIKit
import SwiftyJSON

// max & min coordinates in json

let northmostCoor: CGFloat = 1.83597e+07
let southmostCoor: CGFloat = -2.00375e+07
let westmostCoor: CGFloat = 1.99108e+07
let eastmostCoor: CGFloat = -2.00375e+07

class WorldMapView: UIView {
    
    var lines: [(CGPoint, CGPoint)]

    var coorPerPoint: CGFloat = 0
    var coorCenter = CGPointZero
    
    var midX: CGFloat = 0
    var midY: CGFloat = 0
    
    init(frame: CGRect, lines: [(CGPoint, CGPoint)]) {
        
        self.lines = lines
        
        super.init(frame: frame)
        
        midX = CGRectGetMidX(frame)
        midY = CGRectGetMidY(frame)

        coorPerPoint =  (northmostCoor-southmostCoor)/frame.height
        coorCenter = CGPoint.init(x: 1908835.027993, y: 6107846.252549)
        
        backgroundColor = UIColor.whiteColor()

        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
        let pinchGesture = UIPinchGestureRecognizer.init(target: self, action: #selector(handlePinch(_:)))
        addGestureRecognizer(pinchGesture)
        setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - GESTURES HANDLERS
    
//    func handleTap(tapGesture: UITapGestureRecognizer) {
//        let touchLocation = tapGesture.locationInView(self)
//        coorCenter = coordinateForPoint(touchLocation) // center in touch location
//        setNeedsDisplay() // redraw
//    }
    
    func handlePan(panGesture: UIPanGestureRecognizer) {
        
        let translation = panGesture.translationInView(self)
        
        if abs(translation.x) > 2.5 || abs(translation.y) > 2.5 {
            
            panGesture.setTranslation(CGPointZero, inView: self) // reset translation

            var centerX: CGFloat = coorCenter.x
            var centerY: CGFloat = coorCenter.y
            
            // --
            // stops map from moving beyond edges
            // --
            
            // map moving towards the right
            if translation.x < 0 {
                // check if approaches right edge
                let transRightCoor = coorCenter.x + translation.x*coorPerPoint - midX*coorPerPoint
                if transRightCoor >= eastmostCoor {
                    centerX = coorCenter.x + translation.x*coorPerPoint
                }
                else {
                    centerX = eastmostCoor + midX*coorPerPoint
                }
            }
            // map moving towards the left
            else if translation.x > 0 {
                // check if map reached left edge
                let transLeftCoor = coorCenter.x + translation.x*coorPerPoint + midX*coorPerPoint
                if transLeftCoor <= westmostCoor {
                    centerX = coorCenter.x + translation.x*coorPerPoint
                }
                else {
                    centerX = westmostCoor - midX*coorPerPoint
                }
            }
            // map moving towards the bottom
            if translation.y < 0 {
                // check if map reached bottom edge
                let transLowerCoor = coorCenter.y + translation.y*coorPerPoint - midY*coorPerPoint
                if transLowerCoor >= southmostCoor {
                    centerY = coorCenter.y + translation.y*coorPerPoint
                }
                else {
                    centerY = southmostCoor + midY*coorPerPoint
                }
            }
            // map moving towards the top
            else if translation.y > 0 {
                // check if map reached top edge
                let transTopCoor = coorCenter.y + translation.y*coorPerPoint + midY*coorPerPoint
                if transTopCoor <= northmostCoor {
                    centerY = coorCenter.y + translation.y*coorPerPoint
                }
                else {
                    centerY = northmostCoor - midY*coorPerPoint
                }
            }
            
            coorCenter = CGPoint.init(x: centerX, y: centerY)
            setNeedsDisplay() // redraw view
        }
    }
    
    func handlePinch(pinchGesture: UIPinchGestureRecognizer) {
        let scale = pinchGesture.scale
        let normalizedScale = 1/scale
        let mapHeight = northmostCoor - southmostCoor
        // stops map from getting too zoomed-out
        if scale < 1.0 && coorPerPoint*normalizedScale*frame.height > mapHeight {
            return
        }
        // stops map from getting too zoomed-in
        if scale > 1.0 && coorPerPoint*normalizedScale < 2000 {
            return
        }
        if abs(scale - 1.0) > 0.05 {
            coorPerPoint *= normalizedScale
            setNeedsDisplay() // redraw
        }
    }
    
    // MARK: - CUSTOM DRAWING
    
    override func drawRect(rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
        CGContextSetLineWidth(ctx, 0.2)
        
        for line in lines {
            let coor0 = line.0
            let coor1 = line.1
            let point0 = pointForCoordinate(coor0)
            let point1 = pointForCoordinate(coor1)
            
            if frame.contains(point0) || frame.contains(point1) {
                CGContextMoveToPoint(ctx, point0.x, point0.y)
                CGContextAddLineToPoint(ctx,  point1.x, point1.y)
                CGContextStrokePath(ctx)
            }
        }
    }
    
    // MARK: - UTILITES
    
    func viewContainsCoordinate(x: CGFloat, y: CGFloat) -> Bool {
        if(CGRectContainsPoint(self.frame, CGPoint.init(x: x, y: y))) {
            return true
        }
        return false
    }
    
    func pointForXCoordinate(x: CGFloat) -> CGFloat {
        return (coorCenter.x + x)/coorPerPoint + midX
    }
    
    func pointForYCoordinate(y: CGFloat) -> CGFloat {
        return (coorCenter.y - y)/coorPerPoint + midY
    }
    
    func pointForCoordinate(coor: CGPoint) -> CGPoint {
        return CGPoint.init(x: (coorCenter.x + coor.x)/coorPerPoint + midX, y: (coorCenter.y - coor.y)/coorPerPoint + midY)
    }
    
    func coordinateForPoint(point: CGPoint) -> CGPoint {
        return CGPoint.init(x: ((point.x - midX)*coorPerPoint)-coorCenter.x, y: -(((point.y - midY)*coorPerPoint)-coorCenter.y))
    }
}

