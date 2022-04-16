//
//  ContentView.swift
//  Maps
//
//  Created by Андрей Воробьев on 16.04.2022.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @State private var directions: [String] = []
    @State private var showDirections = false
    
    var body: some View {
        VStack{
            MapView(directions: $directions)
            Button {
                self.showDirections.toggle()
            } label: {
                Text("Show directions")
            }
            .disabled(directions.isEmpty)
            .padding()

        }
        .sheet(isPresented: $showDirections) {
            VStack {
                Text("Directions")
                    .font(.largeTitle).bold().padding()
                Divider().background(Color.blue)
                List{
                    ForEach(0..<self.directions.count, id: \.self) { i in
                        Text(self.directions[i])
                            .padding()
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    @Binding var directions: [String]
    
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        mapView.delegate = context.coordinator
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 59.9, longitude: 30.3), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        mapView.setRegion(region, animated: true)
        
        let p1 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 59.9, longitude: 30.3))
        let p1Annotation = MKPointAnnotation()
        p1Annotation.title = "Санкт-Петербург"
        
        let p2 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 55.75, longitude: 37.61))
        let p2Annotation = MKPointAnnotation()
        p2Annotation.title = "Москва"
        
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: p1)
        request.destination = MKMapItem(placemark: p2)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            
            mapView.addAnnotations([p1Annotation, p2Annotation])
            mapView.addOverlay(route.polyline)
            mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 28, left: 28, bottom: 24, right: 24), animated: true)
            self.directions = route.steps.map {$0.instructions}.filter {!$0.isEmpty}
        }
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
    }
    
    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            return renderer
            
        }
    }
}

