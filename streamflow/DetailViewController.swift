//
//  DetailViewController.swift
//  streamflow
//
//  Created by 周煜杰 on 2020/2/22.
//  Copyright © 2020 周煜杰. All rights reserved.
//

import UIKit
import Charts

struct DetailData {
    let features : [FeatureResult]
    let feature: FeatureResult
}

class DetailViewController: UIViewController {

    @IBOutlet weak var region: UILabel!
    @IBOutlet weak var mean: UILabel!
    @IBOutlet weak var max: UILabel!
    @IBOutlet weak var area: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    
    private var dateformatter : DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
    
    public var data: DetailData? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let features = data?.features, let feature = data?.feature {
            
            self.region.text = feature.region
            self.mean.text =  String(feature.flowmean)
            self.max.text = String(feature.flowmax)
            
            self.area.text = NumberFormatter.localizedString(from: NSNumber(value: feature.drainarea/1000/1000/1000), number: .none)
            
            let date = Date.init(timeIntervalSince1970: TimeInterval(feature.timevalue/1000))
            self.time.text = dateformatter.string(from: date)
            
            features.forEach { f in
                print(f.timevalue, f.flowmean)
            }
            
            // set chart
            let xAxis = chartView.xAxis
            xAxis.labelPosition = .topInside
            xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
            xAxis.labelTextColor = UIColor(red: 255/255, green: 192/255, blue: 56/255, alpha: 1)
            xAxis.drawAxisLineEnabled = false
            xAxis.drawGridLinesEnabled = true
            xAxis.centerAxisLabelsEnabled = true
            xAxis.granularity = 3600
            xAxis.valueFormatter = DateValueFormatter()
            
            chartView.dragEnabled = false
            chartView.setScaleEnabled(false)
            chartView.pinchZoomEnabled = false
            
            chartView.legend.form = .line
            
            setChartData(features: features)
        }
    }
    
    
    func setChartData(features: [FeatureResult]) {
        let values = features.map { (feature) -> ChartDataEntry in
            return ChartDataEntry(x: Double(feature.timevalue), y: feature.flowmean)
        }
        
        let set1 = LineChartDataSet(entries: values, label: "Mean")
        set1.drawIconsEnabled = false
        
        set1.lineDashLengths = [5, 2.5]
        set1.highlightLineDashLengths = [5, 2.5]
        set1.setColor(.black)
        set1.setCircleColor(.black)
        set1.lineWidth = 1
        set1.circleRadius = 3
        set1.drawCircleHoleEnabled = false
        set1.valueFont = .systemFont(ofSize: 9)
        set1.formLineDashLengths = [5, 2.5]
        set1.formLineWidth = 1
        set1.formSize = 15
        
        let gradientColors = [ChartColorTemplates.colorFromString("#00ff0000").cgColor,
                              ChartColorTemplates.colorFromString("#ffff0000").cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        
        set1.fillAlpha = 1
        set1.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
        set1.drawFilledEnabled = true
        
        let data = LineChartData(dataSet: set1)
        
        chartView.data = data
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


class DateValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "dd MMM HH:mm"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value/1000))
    }
}
