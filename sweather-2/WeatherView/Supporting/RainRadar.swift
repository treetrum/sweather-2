//
//  RainRadar.swift
//  sweather-2
//
//  Created by Sam Davis on 17/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI
import MapKit
import GoogleMobileAds

class MapImageIndexManager: ObservableObject {

    @ObservedObject var mapDataManager: MapDataManager
    @Published var image: UIImage?
    @Published var index: Int {
        didSet {
            if let image = self.mapDataManager.images[self.index] {
                self.image = image
            }
        }
    }
    
    init(manager: MapDataManager) {
        self.mapDataManager = manager
        self.index = 0
    }
}

struct RainRadar: View {
    
    @ObservedObject var indexManager: MapImageIndexManager
    @ObservedObject var mapDataManager: MapDataManager
    @State var timer: Timer.TimerPublisher = Timer.publish (every: 0.5, on: .main, in: .common)
    @State var unmounting = false
    
    init(locationId: Int) {
        let mapDataManager = MapDataManager(locationId: locationId)
        self.mapDataManager = mapDataManager
        self.indexManager = MapImageIndexManager(manager: MapDataManager(locationId: locationId))
        self.letsGo()
    }
    
    func letsGo() {
        if let mapdata = self.mapDataManager.mapData {
            let delayAmount = self.indexManager.index == mapdata.overlays.count - 1 ? 1.0 : 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + delayAmount) {
                self.indexManager.index = (self.indexManager.index + 1) % mapdata.overlays.count
                if !self.unmounting {
                    self.letsGo()
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !self.unmounting {
                    self.letsGo()
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            if !mapDataManager.loading && mapDataManager.mapData != nil {
                ZStack {
                    MapView(image: self.indexManager.image, mapData: mapDataManager.mapData!)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        AdBanner()
                        Spacer()
                    }
                    VStack {
                        MapProgressIndicator(progress: Double(Double(self.indexManager.index) * 1.0 / Double(mapDataManager.mapData!.overlays.count - 1)))
                        Spacer()
                    }
                }
            } else {
                Text("Loading map data...")
            }
        }
        .onDisappear {
            self.unmounting = true
        }
    }
}

func createMKMapRect(minLat: Double, minLng: Double, maxLat: Double, maxLng: Double) -> MKMapRect {
    let coordinate1 = CLLocationCoordinate2DMake(minLat, minLng)
    let coordinate2 = CLLocationCoordinate2DMake(maxLat, maxLng)
    let p1 = MKMapPoint(coordinate2);
    let p2 = MKMapPoint(coordinate1);
    let mapRect = MKMapRect(x: fmin(p1.x,p2.x), y: fmin(p1.y,p2.y), width: fabs(p1.x-p2.x), height: fabs(p1.y-p2.y));
    return mapRect
}

extension MKMapView {
    func setMapBounds(minLat: Double, minLng: Double, maxLat: Double, maxLng: Double) {
        let mapRect = createMKMapRect(minLat: minLat, minLng: minLng, maxLat: maxLat, maxLng: maxLng)
        self.setVisibleMapRect(mapRect, animated: true)
    }
}

class ImageOverlay : NSObject, MKOverlay {
    var image: UIImage
    let boundingMapRect: MKMapRect
    let coordinate:CLLocationCoordinate2D
    
    init(image: UIImage, rect: MKMapRect) {
        self.image = image
        self.boundingMapRect = rect
        self.coordinate = rect.origin.coordinate
    }
}

class ImageOverlayRenderer : MKOverlayRenderer {
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        guard let overlay = self.overlay as? ImageOverlay else {
            return
        }
        let rect = self.rect(for: overlay.boundingMapRect)
        UIGraphicsPushContext(context)
        overlay.image.draw(in: rect)
        UIGraphicsPopContext()
    }
}

final class MapView: NSObject, UIViewRepresentable {
    
    let image: UIImage?
    let mapData: WWMapData

    init(image: UIImage?, mapData: WWMapData) {
        self.image = image
        self.mapData = mapData
    }
    
    static func dismantleUIView(_ mapView: MKMapView, coordinator: Coordinator) {
        mapView.removeOverlays(mapView.overlays)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mv = MKMapView()
        mv.delegate = context.coordinator
        mv.setMapBounds(
            minLat: mapData.bounds.minLat,
            minLng: mapData.bounds.minLng,
            maxLat: mapData.bounds.maxLat,
            maxLng: mapData.bounds.maxLng
        )
        mv.showsUserLocation = true
        return mv
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays)
        if let image = self.image {
            if let overlay = context.coordinator.overlays[image] {
                mapView.addOverlay(overlay)
            } else {
                let overlay = ImageOverlay(
                    image: image,
                    rect: createMKMapRect(
                        minLat: mapData.bounds.minLat,
                        minLng: mapData.bounds.minLng,
                        maxLat: mapData.bounds.maxLat,
                        maxLng: mapData.bounds.maxLng
                    )
                )
                mapView.addOverlay(overlay)
                context.coordinator.overlays[image] = overlay
            }
        }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var overlays = [UIImage: MKOverlay]()
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay is ImageOverlay {
                return ImageOverlayRenderer(overlay: overlay)
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    static func getImageAsync(_ urlString: String, completion: @escaping (UIImage) -> Void) {
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            }.resume()
        }
    }
}

struct RainRadar_Previews: PreviewProvider {
    static var previews: some View {
        RainRadar(locationId: 158)
    }
}
