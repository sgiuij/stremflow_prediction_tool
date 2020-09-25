//
//  TimeSetting.swift
//  streamflow
//
//  Created by 周煜杰 on 2020/3/7.
//  Copyright © 2020 周煜杰. All rights reserved.
//

import Foundation

struct TimeSetting {
    var beginDate: Date
    var endDate: Date
    // The default time step interval is 3h, may be need add a input to set?
    var stepInterval: Int = 3*60*60
    var timeRange: Double = 24*60*60

    static var calendar: Calendar{
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        return calendar
    }

    static let minimumDate = calendar.startOfDay(for: Date()).addingTimeInterval(-1*24*60*60)
    static let maximumDate = calendar.startOfDay(for: Date()).addingTimeInterval(5*24*60*60)

    static let defaultSetting = TimeSetting(beginDate: TimeSetting.minimumDate, endDate: TimeSetting.maximumDate)
}
