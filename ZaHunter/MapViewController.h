//
//  MapViewController.h
//  ZaHunter
//
//  Created by Rockstar. on 3/25/15.
//  Copyright (c) 2015 Fantastik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pizzeria.h"

@interface MapViewController : UIViewController
@property NSMutableArray *pizzerias;
@property Pizzeria *mapPizzeria;
@property CLLocation *userLocation;

@end
