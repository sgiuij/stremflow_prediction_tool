//
//  TimeSilderView.swift
//  streamflow
//
//  Created by 周煜杰 on 2020/3/14.
//  Copyright © 2020 周煜杰. All rights reserved.
//

import UIKit
import ArcGIS

protocol TimeSliderDelegate {
    func getTime(timeExtent: AGSTimeExtent)
}

@IBDesignable
class TimeSilderView: UIView {
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    
    public var delegate: TimeSliderDelegate? = nil
    
    private var dateformatter : DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }
    
    var currentTime: Date = TimeSetting.minimumDate {
        didSet {
            timeLabel.text = dateformatter.string(from: currentTime)
            delegate?.getTime(timeExtent: AGSTimeExtent(startTime: currentTime, endTime: currentTime.addingTimeInterval(timeInterval)))
        }
    }
    private let startTime = TimeSetting.minimumDate
    private let endTime = TimeSetting.maximumDate
    private let timeInterval = TimeInterval(3*60*60)
    private let stepInterval = TimeInterval(2) // 2s
    
    private var timer: Timer?
    public var isPlaying = false {
        didSet {
            if isPlaying {
                playButton.setImage(UIImage(named: "Pause"), for: .normal)
                timer?.invalidate()
                timer = Timer.scheduledTimer(timeInterval: stepInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
            } else {
                playButton.setImage(UIImage(named: "Play"), for: .normal)
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    var totStep: Int {
        get {
            return Int(startTime.distance(to: endTime) / timeInterval) - 1
        }
    }
    
    private var currentStep: Int! {
        didSet {
            if currentStep <= totStep {
                slider.value = Float(currentStep) / Float(totStep)
                currentTime = startTime.addingTimeInterval(TimeInterval(currentStep * Int(timeInterval)))
            } else {
                isPlaying = false
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initFromXIB()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initFromXIB()
    }
    
    func initFromXIB() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "TimeSilderView", bundle: bundle)
        let content = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        addSubview(content)
        slider.value = 0
        currentStep = 0
        
        setAction()
    }
    
    func setAction() {
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        slider.addTarget(self, action: #selector(slide), for: .touchUpInside)
        leftButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(forward), for: .touchUpInside)
    }
    
    @objc
    func play() {
        print("play")
        isPlaying = !isPlaying
    }
    
    @objc
    func slide() {
        print("slide", self.slider.value)
        currentStep = Int(Float(totStep) * self.slider.value)
    }
    
    @objc
    func back() {
        if !isPlaying && currentStep > 0 {
            currentStep -= 1
        }
    }
    
    @objc
    func forward() {
        if (!isPlaying && currentStep < totStep) {
            currentStep += 1
        }
    }
    
    @objc
    private func timerAction() {
        currentStep += 1
    }
}
