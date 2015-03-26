//
//  MapViewController.m
//  ZaHunter
//
//  Created by Rockstar. on 3/25/15.
//  Copyright (c) 2015 Fantastik. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
@interface MapViewController ()<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property MKRoute *destinationRoute;
@property CLPlacemark *destinationPlacemark;
@property MKPointAnnotation *pizzaAnnotation;


@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.pizzaAnnotation = [MKPointAnnotation new];

    if (self.pizzerias.count > 4) {
        for (int k = 0; k < 4; k++) {
            self.mapPizzeria = [self.pizzerias objectAtIndex:k];
            MKPointAnnotation *annotation = [MKPointAnnotation new];
            annotation.coordinate = self.mapPizzeria.mapItem.placemark.location.coordinate;
            annotation.title = self.mapPizzeria.mapItem.name;
            
            [self.mapView addAnnotation:annotation];
        }
    }

//    for (Pizzeria *mapPizzeria in self.pizzerias) {
//        MKPointAnnotation *annotation = [MKPointAnnotation new];
//        annotation.coordinate = mapPizzeria.mapItem.placemark.location.coordinate;
//        annotation.title = mapPizzeria.mapItem.name;
//        [self.mapView addAnnotation:annotation];
//    }

    self.mapView.showsUserLocation = YES;
}


- (void)viewDidAppear:(BOOL)animated {
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    Pizzeria *newAnnotation = annotation;
    if (annotation == mapView.userLocation) {
        return nil;
    }

    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    pin.canShowCallout = YES;

    newAnnotation.title = newAnnotation.title;
    pin.image = [UIImage imageNamed:@"pizza"];
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return pin;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *route = overlay;
        MKPolylineRenderer *rendered = [[MKPolylineRenderer alloc] initWithPolyline:route];
        rendered.strokeColor = [UIColor colorWithRed:0.99 green:0.55 blue:0.31 alpha:1.00];
        rendered.lineWidth = 5.0;
        return rendered;
    }
    else {
        return nil;
    }
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    CLLocationCoordinate2D pin = view.annotation.coordinate;
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];

    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:pin addressDictionary:nil];
    MKMapItem *destItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    request.destination = destItem;

    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            self.destinationRoute = response.routes.lastObject;
            [self.mapView addOverlay:self.destinationRoute.polyline level:MKOverlayLevelAboveRoads];
        }
    }];

}

- (void)getDirections {

}

- (void)plotRoute:(MKDirectionsResponse *)response {
    for (MKRoute *route in response.routes) {
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }
}

- (void)getDirections:(MKMapItem *)destination {
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = destination;

    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        MKRoute *route = response.routes.firstObject;
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }];
}





@end
