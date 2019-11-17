//
//  RainRadar.swift
//  sweather-2
//
//  Created by Sam Davis on 17/11/19.
//  Copyright © 2019 Sam Davis. All rights reserved.
//

import SwiftUI
import MapKit

struct RainRadar: View {
    
    @ObservedObject var mapDataManager: MapDataManager
    
    init(locationId: Int) {
        self.mapDataManager = MapDataManager(locationId: locationId)
    }
    
    var body: some View {
        VStack {
            if mapDataManager.mapData != nil {
                MapView().frame(height: 300)
            } else {
                Text("Loading map data...")
            }
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
    let image:UIImage
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

final class MapView: NSObject, UIViewRepresentable, MKMapViewDelegate {
    
    var mapView: MKMapView?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = self
        mapView.setMapBounds(minLat: -36.051, minLng: 148.51, maxLat: -31.351, maxLng: 153.91)
        
        let url = URL(string:"https://cdnmaps.willyweather.com.au/radar/71-201911170754.png")
        
        if let data = try? Data(contentsOf: url!) {
            let image: UIImage = UIImage(data: data)!
            let overlay = ImageOverlay(image: image, rect: createMKMapRect(minLat: -36.051, minLng: 148.51, maxLat: -31.351, maxLng: 153.91))
            mapView.addOverlay(overlay)
        }
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is ImageOverlay {
            return ImageOverlayRenderer(overlay: overlay)
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

struct RainRadar_Previews: PreviewProvider {
    static var previews: some View {
        RainRadar(locationId: 158)
    }
}
