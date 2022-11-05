//
//  SWWeatherService.swift
//  sweather-2
//
//  Created by Samuel Davis on 5/11/2022.
//  Copyright © 2022 Sam Davis. All rights reserved.
//

import Foundation
import WeatherKit
import CoreLocation

struct SWWeatherService {
    
    enum Errors: Error {
        case geocodingFailure
    }
    
    private let weatherService = WeatherService()
    
    private func geocodeCoords(_ coords: CLLocationCoordinate2D) async throws -> (CLPlacemark, CLLocation) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coords.latitude, longitude: coords.longitude)
        let geocoded = try await geocoder.reverseGeocodeLocation(location)
        if let place = geocoded.first, let location = place.location {
            return (place, location)
        }
        throw Errors.geocodingFailure
    }
    
    func getWeatherForCoords(coords: CLLocationCoordinate2D) async throws -> SWWeather  {
        let (place, location) = try await geocodeCoords(coords)
        let weather = try await weatherService.weather(for: location)
        return SWWeather(weather: weather, place: place)
    }
    
    func getWeatherForCustomLocation(location: CustomLocation) async throws -> SWWeather {
        let geocoder = CLGeocoder()
        let addressStr = "\(location.displayString) \(location.state ?? "") \(location.postcode ?? "")"
        let places = try await geocoder.geocodeAddressString(addressStr)
        if let place = places.first, let loc = place.location {
            return try await getWeatherForCoords(coords: loc.coordinate)
        } else {
            throw Errors.geocodingFailure
        }
    }
}
