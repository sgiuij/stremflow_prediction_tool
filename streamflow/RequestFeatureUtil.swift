//
//  RequestFeatureUtil.swift
//  streamflow
//
//  Created by 周煜杰 on 2020/2/22.
//  Copyright © 2020 周煜杰. All rights reserved.
//

import Foundation

struct FeatureResult {
    //egdb.dbo.GlobalScale.region: "Niger_River"
    let region:String
    //    egdb.dbo.global_medium_term_current.flowmean: 9962.8
    let flowmean:Double
    
    //    egdb.dbo.global_medium_term_current.flowmax: 9962.8
    let flowmax:Double

    //    egdb.dbo.GlobalScale.drainarea: 577023755279 //577,024 km²
    let drainarea:Double
//    egdb.dbo.global_medium_term_current.timevalue: 1582243200000
    let timevalue:Int
}

class RequestFeatureUtil{
    
    private static let interval = TimeInterval(12*60*60)
    
    private static func rawURL(x:Double, y:Double, time: Date) -> URL {
        let rawURL =  """
http://livefeeds2.arcgis.com/arcgis/rest/services/GEOGLOWS/GlobalWaterModel_Medium/MapServer/0/query?\
f=json&\
returnGeometry=true&\
spatialRel=esriSpatialRelIntersects&\
maxAllowableOffset=611.4962262812475&\
geometry=%7B%22xmin%22%3A\(x-5000)%2C%22ymin%22%3A\(y-5000)%2C%22xmax%22%3A\(x+5000)%2C%22ymax%22%3A\(y+5000)%2C%22spatialReference%22%3A%7B%22wkid%22%3A102100%2C%22latestWkid%22%3A3857%7D%7D&\
geometryType=esriGeometryEnvelope&\
inSR=102100&\
outSR=102100&\
time=\(time.timeIntervalSince1970*1000)&\
outFields=egdb.dbo.GlobalScale.objectid%2Cegdb.dbo.GlobalScale.shape%2Cegdb.dbo.GlobalScale.watershed%2Cegdb.dbo.GlobalScale.subbasin%2Cegdb.dbo.GlobalScale.region%2Cegdb.dbo.GlobalScale.comid%2Cegdb.dbo.global_medium_term_current.timevalue%2Cegdb.dbo.global_medium_term_current.flowmean%2Cegdb.dbo.global_medium_term_current.flowmax%2Cegdb.dbo.GlobalScale.drainarea%2Cegdb.dbo.GlobalScale.downstreamid%2Cegdb.dbo.GlobalScale.streamorder%2Cegdb.dbo.global_medium_term_current.flowstyle%2Cegdb.dbo.global_medium_term_current.flowclass
"""
        return URL(string: rawURL)!
    }
    
    private static func respondHandler(data: Data?, resp: URLResponse?, error: Error?) -> FeatureResult? {
        let dictionary = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
        if let root = dictionary as? [String : Any], let features = (root["features"] as? [[String : Any]]){
            if features.count == 0  {
                print("no result")
                return nil
            } else {
                if let attributes = features[0]["attributes"] as? [String : Any] {
                    return FeatureResult.init(
                        region: attributes["egdb.dbo.GlobalScale.region"] as! String,
                        flowmean: attributes["egdb.dbo.global_medium_term_current.flowmean"] as! Double,
                        flowmax: attributes["egdb.dbo.global_medium_term_current.flowmax"] as! Double,
                        drainarea: attributes["egdb.dbo.GlobalScale.drainarea"] as! Double,
                        timevalue: attributes["egdb.dbo.global_medium_term_current.timevalue"] as! Int
                    )
                } else {
                    print("no result")
                    return nil
                }
            }
        }
        return nil
    }
    
    static func getFeatures(x:Double, y:Double, complete: @escaping([FeatureResult]) -> ()){
        
        // xmin, ymin, xmax, ymax 的计算方法需要看一下js源码，姑且先这样简单粗暴的处理_
//        let
        let session = URLSession(configuration: .default)
        let semaphore = DispatchSemaphore(value: 0)
        var results : [FeatureResult] = []
        
        var time = TimeSetting.minimumDate
        
        print("start")
        while time < TimeSetting.maximumDate {
            print("task", time)
            let request = URLRequest(url: rawURL(x: x, y: y, time: time))
            let task = session.dataTask(with: request){ (data, resp, error) in
                if let result = respondHandler(data: data, resp: resp, error: error) {
                    results.append(result)
                }
                semaphore.signal()
            }
            time = time.addingTimeInterval(interval)
            task.resume()
            semaphore.wait()
        }
        semaphore.signal()
        _ = semaphore.wait(timeout: .distantFuture)
        print("end")
        complete(results)
    }
    
    static func getFeatureByTime(x:Double, y:Double, time: Date, complete: @escaping(FeatureResult?) -> ()){
        let session = URLSession(configuration: .default)
        let request = URLRequest(url: rawURL(x: x, y: y, time: time))
        let task = session.dataTask(with: request){ (data, resp, error) in
            let result = respondHandler(data: data, resp: resp, error: error)
            complete(result)
        }
        task.resume()
    }
}
