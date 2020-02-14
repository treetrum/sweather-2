//
//  ComplicationController.swift
//  sweather-watch Extension
//
//  Created by Sam Davis on 9/2/20.
//  Copyright © 2020 Sam Davis. All rights reserved.
//

import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        let currentDate = Date()
        handler(currentDate)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        let currentDate = Date().addingTimeInterval(24 * 60 * 60)
        handler(currentDate)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        if complication.family == .modularSmall {
            let template = CLKComplicationTemplateModularSmallSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: "21.1°")
            let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(timelineEntry)
        }
        else if complication.family == .graphicCircular {
            
            if let data = SharedSWWeatherData.shared.weatherData {
                
                let template = CLKComplicationTemplateGraphicCircularOpenGaugeRangeText()
                
                let min = data.days.first!.min!
                let max = data.days.first!.max!
                let current = data.temperature.actual!.roundToFloor()
                let diff = max - min
                let percent = Float(Float(current)! - Float(min)) / Float(diff)
                let safePercent = percent < 0 ? 0 : percent > 1 ? 1 : percent

                template.centerTextProvider = CLKSimpleTextProvider(text: "\(current)")
                template.leadingTextProvider = CLKSimpleTextProvider(text: "\(min)")
                template.trailingTextProvider = CLKSimpleTextProvider(text: "\(max)")
                
                template.gaugeProvider = CLKSimpleGaugeProvider(style: .ring, gaugeColor: UIColor(hexString: "C92D2D"), fillFraction: safePercent)
                let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
                handler(timelineEntry)
                
            } else {
                handler(nil)
            }
            
        }
        else {
            handler(nil)
        }
        
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        if complication.family == .modularSmall {
            let template = CLKComplicationTemplateModularSmallSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: "21.1°")
            handler(template)
        } else if complication.family == .graphicCircular {
            let template = CLKComplicationTemplateGraphicCircularOpenGaugeRangeText()
            template.centerTextProvider = CLKSimpleTextProvider(text: "15.0")
            template.leadingTextProvider = CLKSimpleTextProvider(text: "10")
            template.trailingTextProvider = CLKSimpleTextProvider(text: "20")
            template.gaugeProvider = CLKSimpleGaugeProvider(style: .ring, gaugeColor: .red, fillFraction: 0.5)
            handler(template)
        } else {
            handler(nil)
        }
        
    }
    
}
