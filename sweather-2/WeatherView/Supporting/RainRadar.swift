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
    @State var imageIndex = 0;
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(locationId: Int) {
        self.mapDataManager = MapDataManager(locationId: locationId)
    }
    
    var body: some View {
        VStack {
            if mapDataManager.mapData != nil {
                VStack {
//                    Text("Progress indicator")
                    MapView(imageIndex: self.$imageIndex, mapData: mapDataManager.mapData!)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                }
            } else {
                Text("Loading map data...")
            }
        }.onReceive(timer) { _ in
            if let mapdata = self.mapDataManager.mapData {
                self.imageIndex = (self.imageIndex + 1) % mapdata.overlays.count
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
    
    @Binding var imageIndex: Int
    let mapData: WWMapData
    
    init(imageIndex: Binding<Int>, mapData: WWMapData) {
        self._imageIndex = imageIndex
        self.mapData = mapData
    }
    
    static func dismantleUIView(_ mapView: MKMapView, coordinator: Coordinator) {
        for overlay in mapView.overlays {
            mapView.removeOverlay(overlay)
        }
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
        if let image = MapView.getImageFromURLString(url: "\(mapData.overlayPath)\(mapData.overlays[self.imageIndex].name)") {
            let newOverlay = ImageOverlay(
                image: image,
                rect: createMKMapRect(
                    minLat: mapData.bounds.minLat,
                    minLng: mapData.bounds.minLng,
                    maxLat: mapData.bounds.maxLat,
                    maxLng: mapData.bounds.maxLng
                )
            )
            if let oldOverlay = context.coordinator.overlay {
                mapView.removeOverlay(oldOverlay)
            }
            context.coordinator.overlay = newOverlay
            mapView.addOverlay(newOverlay)
        }
    }
    
    static func getImageFromURLString(url urlString: String) -> UIImage? {
        if let url = URL(string: urlString), let data = try? Data(contentsOf: url) {
            let image = UIImage(data: data)
            return image
        }
        return nil;
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var overlay: ImageOverlay?
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay is ImageOverlay {
                return ImageOverlayRenderer(overlay: overlay)
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

struct RainRadar_Previews: PreviewProvider {
    static var previews: some View {
        RainRadar(locationId: 158)
    }
}
