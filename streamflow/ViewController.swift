//
//  MainViewController.swift
//  streamflow
//
//  Created by 周煜杰 on 2020/2/4.
//  Copyright © 2020 周煜杰. All rights reserved.
//

import UIKit
import ArcGIS
import SVProgressHUD

class ViewController: UIViewController, AGSGeoViewTouchDelegate, TimeSliderDelegate {
    
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var timeSlider: TimeSilderView!
    
    private var map = AGSMap(basemap: .topographic())
    var lat: Double = 0.0
    var long: Double = 0.0
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //initialize map with topographic basemap
        //assign map to the map view
        self.mapView.map = self.map
        //register as the map view's touch delegate
        //in order to get tap notifications
        self.mapView.touchDelegate = self
        self.mapView.setViewpointCenter(AGSPoint(x: -1.2e7, y: 5e6, spatialReference: .webMercator()), scale: 4e7)
        //create a map image layer using a url
        // https://livefeeds2.arcgis.com/arcgis/rest/services/GEOGLOWS/GlobalWaterModel_Medium/MapServer
        // https://sampleserver5.arcgisonline.com/arcgis/rest/services/Elevation/WorldElevations/MapServer
        let mapImageLayer = AGSArcGISMapImageLayer(url: URL(string: "http://livefeeds2.arcgis.com/arcgis/rest/services/GEOGLOWS/GlobalWaterModel_Medium/MapServer")!)
        self.map.operationalLayers.add(mapImageLayer)
        timeSlider.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(),for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController,
            let controller = navigationController.viewControllers.first as? DetailViewController {
            if let data = sender as? DetailData {
                controller.data = data
            }
        }
    }
    
    //user tapped on the map
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        lat = mapPoint.x
        long = mapPoint.y
        print(lat, long)
        SVProgressHUD.show(withStatus: "Querying")
        DispatchQueue.global().async {
            RequestFeatureUtil.getFeatureByTime(x: self.lat, y: self.long, time: self.timeSlider.currentTime) {[weak self] (result) in
                if let result = result, let self = self {
                    RequestFeatureUtil.getFeatures(x: self.lat, y: self.long) {[weak self] (results) in
                        SVProgressHUD.dismiss()
                        DispatchQueue.main.async {
                            self?.performSegue(withIdentifier: "showDetail", sender: DetailData(features: results, feature: result))
                        }
                    }
                } else {
                    SVProgressHUD.showError(withStatus: "No Results!")
                }
            }
        }
    }
    
    func getTime(timeExtent: AGSTimeExtent) {
        mapView.timeExtent = timeExtent
    }
}
