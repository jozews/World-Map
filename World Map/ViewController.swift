//
//  ViewController.swift
//  World Map
//
//  Created by Jože Ws on 8/26/16.
//  Copyright © 2016 JožeWs. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {
    
    // MARK: VIEW CONTROLLER
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let path = NSBundle.mainBundle().pathForResource("countries_small", ofType: "geojson")!
        if let jsonData = NSData.init(contentsOfFile: path) {
            let json = JSON(data: jsonData)
            let features = json["features"].array!
            let lines = createLines(features)
            let worldMapView = WorldMapView.init(frame: view.frame, lines: lines)
            self.view = worldMapView
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UTILITIES

    // removes duplicate lines (borders) and creates and array of lines (2 points)
    
    func createLines(features: [JSON]) -> [(CGPoint, CGPoint)] {
        var lines: [(CGPoint, CGPoint)] = []
        for feature in features {
            if feature["properties"]["name"].string == "Austria" {
                print(feature)
            }
            let geoType = feature["geometry"]["type"].string
            if geoType == "Polygon" {
                let polygon = feature["geometry"]["coordinates"].array!
                var lastPoint = CGPointZero
                for coordinates in polygon {
                    for (idx, coordinate) in coordinates.array!.enumerate() {
                        if idx == 0 {
                            lastPoint = CGPoint.init(x: coordinate[0].double!, y: coordinate[1].double!)
                        }
                        else {
                            let point = CGPoint.init(x: coordinate[0].double!, y: coordinate[1].double!)
                            let line = (lastPoint, point)
                            lastPoint = point
                            lines.append(line)
                        }
                    }
                }
            }
            else if geoType == "MultiPolygon" {
                let multiPolygon = feature["geometry"]["coordinates"].array!
                for polygon in multiPolygon {
                    var lastPoint = CGPointZero
                    for coordinates in polygon.array! {
                        for (idx, coordinate) in coordinates.array!.enumerate() {
                            if idx == 0 {
                                lastPoint = CGPoint.init(x: coordinate[0].double!, y: coordinate[1].double!)
                            }
                            else {
                                let point = CGPoint.init(x: coordinate[0].double!, y: coordinate[1].double!)
                                let line = (lastPoint, point)
                                lastPoint = point
                                lines.append(line)
                            }
                        }
                    }
                }
            }
        }
        return lines
    }
}
