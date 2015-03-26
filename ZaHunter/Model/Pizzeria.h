//
//  Pizzeria.h
//  ZaHunter
//
//  Created by Rockstar. on 3/25/15.
//  Copyright (c) 2015 Fantastik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Pizzeria : MKPointAnnotation

@property MKPointAnnotation *pointAnnotation;
@property CLLocationDistance locationDistance;
@property MKMapItem *mapItem;
@property NSString *locationAddress;
@property MKRoute *routeDetails;
@property MKPlacemark *placemark;
@property NSString *rating;


@end
