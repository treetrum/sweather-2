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

struct RainRadar: View {
    
    @ObservedObject var mapDataManager: MapDataManager
    @State var imageIndex = 0;
    @State var timer: Timer.TimerPublisher = Timer.publish (every: 1, on: .main, in: .common)
    var sessionData = SessionData.shared
    
    init(locationId: Int) {
        self.mapDataManager = MapDataManager(locationId: locationId)
    }
    
    var body: some View {
        VStack {
            if !mapDataManager.loading && mapDataManager.mapData != nil {
                ZStack {
                    MapView(imageIndex: self.$imageIndex, mapData: mapDataManager.mapData!)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                    if !self.sessionData.hasAdRemovalSubscription {
                        VStack {
                            Banner().frame(height: kGADAdSizeBanner.size.height).listRowInsets(EdgeInsets())
                            Spacer()
                        }
                        
                    }
                    VStack {
                        MapProgressIndicator(progress: Double(Double(self.imageIndex) * 1.0 / Double(mapDataManager.mapData!.overlays.count - 1)))
                        Spacer()
                    }
                }
            } else {
                Text("Loading map data...")
            }
        }.onReceive(timer) { _ in
            if let mapdata = self.mapDataManager.mapData {
                self.imageIndex = (self.imageIndex + 1) % mapdata.overlays.count
            }
        }
        .onAppear(perform: {
            self.timer = Timer.publish(every: 1, on: .main, in: .common)
            let _ = self.timer.connect()
        })
        .onDisappear {
            self.timer.connect().cancel()
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
    var images = [UIImage]()
    var overlays = [MKOverlay]()
    
    init(imageIndex: Binding<Int>, mapData: WWMapData) {
        self._imageIndex = imageIndex
        self.mapData = mapData
        for overlay in self.mapData.overlays {
            if let image = MapView.getImageFromURLString(url: "\(mapData.overlayPath)\(overlay.name)") {
                self.overlays.append(ImageOverlay(
                    image: image,
                    rect: createMKMapRect(
                        minLat: mapData.bounds.minLat,
                        minLng: mapData.bounds.minLng,
                        maxLat: mapData.bounds.maxLat,
                        maxLng: mapData.bounds.maxLng
                    )
                ))
            }
        }
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
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(self.overlays[self.imageIndex])
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
