//
// Copyright (C) 2005-2021 Alfresco Software Limited.
//
// This file is part of the Alfresco Content Mobile iOS App.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import UIKit
import CoreLocation

typealias GPSLocation = NSMutableDictionary

protocol LocationServiceProtocol {
    
    /// Request auhtorization from user to use location.
    func requestAuhtorizationForLocatioInUse()
    
    /// Start creating and updating locations
    func requestLocation()
    
    /// Start updating location
    func startUpdatingLocation()
    
    /// Stop updating location
    func stopUpdatingLocation()
    
    /// Transfrom last location into Dictonary
    func lastGPSLocation() -> GPSLocation?
}

class LocationService: NSObject, Service, LocationServiceProtocol {
    private var locationManager: CLLocationManager
    private var lastLocation: CLLocation?
    
    override init() {
        locationManager = CLLocationManager()
    }
    
    // MARK: - Public Methods
    
    func requestAuhtorizationForLocatioInUse() {
        locationManager.requestWhenInUseAuthorization()
        requestLocation()
    }
    
    func requestLocation() {
        lastLocation = nil
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func lastGPSLocation() -> GPSLocation? {
        if !locationManagerHasAuthorizationForUsage() {
            return nil
        }
        return gpsLocation()
    }
    
    // MARK: - Private Methods
    
    private func locationManagerHasAuthorizationForUsage() -> Bool {
        if locationManager.authorizationStatus == .notDetermined ||
            locationManager.authorizationStatus == .denied ||
            locationManager.authorizationStatus == .restricted {
            return false
        }
        return true
    }
    
    private func gpsLocation() -> GPSLocation? {
        guard let location = lastLocation else { return nil }

        let gpsDictionary = GPSLocation()
        var latitude = location.coordinate.latitude
        var longitude = location.coordinate.longitude
        var altitude = location.altitude
        var latitudeRef = "N"
        var longitudeRef = "E"
        var altitudeRef = 0
        
        if latitude < 0.0 {
            latitude = -latitude
            latitudeRef = "S"
        }
        
        if longitude < 0.0 {
            longitude = -longitude
            longitudeRef = "W"
        }
        
        if altitude < 0.0 {
            altitude = -altitude
            altitudeRef = 1
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd"
        gpsDictionary[kCGImagePropertyGPSDateStamp] = formatter.string(from: location.timestamp)
        formatter.dateFormat = "HH:mm:ss"
        gpsDictionary[kCGImagePropertyGPSTimeStamp] = formatter.string(from: location.timestamp)
        gpsDictionary[kCGImagePropertyGPSLatitudeRef] = latitudeRef
        gpsDictionary[kCGImagePropertyGPSLatitude] = latitude
        gpsDictionary[kCGImagePropertyGPSLongitudeRef] = longitudeRef
        gpsDictionary[kCGImagePropertyGPSLongitude] = longitude
        gpsDictionary[kCGImagePropertyGPSDOP] = location.horizontalAccuracy
        gpsDictionary[kCGImagePropertyGPSAltitudeRef] = altitudeRef
        gpsDictionary[kCGImagePropertyGPSAltitude] = altitude
        
        if let heading = locationManager.heading {
            gpsDictionary[kCGImagePropertyGPSImgDirectionRef] = "T"
            gpsDictionary[kCGImagePropertyGPSImgDirection] = heading.trueHeading
        }
        
        return gpsDictionary
    }
}

// MARK: - CLLocationManager Delegate

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.first
        CameraKit.location = lastGPSLocation()
    }
}

