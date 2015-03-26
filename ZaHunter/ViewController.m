//
//  ViewController.m
//  ZaHunter
//
//  Created by Rockstar. on 3/25/15.
//  Copyright (c) 2015 Fantastik. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "Pizzeria.h"
#import "MapViewController.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *switchSegmentControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapButtonItem;
@property (weak, nonatomic) IBOutlet UITableView *pizzaTableView;
@property CLLocationManager *locationManager;
@property NSMutableString *directionSting;
@property NSMutableArray *pizzeriaArray;
@property NSTimeInterval timeToLocation;
@property CLLocation *userLocation;
@property Pizzeria *mainPizzeria;
@property UITextView *footerTextView;
@property NSString *ratingString;
@property UILabel *foterLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pizzeriaArray = [NSMutableArray new];
    self.foterLabel = [UILabel new];
//    self.ratingArray = [NSMutableArray new];
    [self loadUserLocation];

}

#pragma mark - Helper Methods




#pragma mark - UITableviewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.pizzeriaArray.count < 4) {
        return self.pizzeriaArray.count;
    } else {
        return 4;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    Pizzeria *pizzeria = [self.pizzeriaArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", pizzeria.mapItem.name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f MI", pizzeria.locationDistance];
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 3)];
    footer.backgroundColor = [UIColor colorWithRed:0.99 green:0.55 blue:0.31 alpha:1.00];
//
    self.footerTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, tableView.tableFooterView.frame.size.height)];
    self.footerTextView.backgroundColor = [UIColor clearColor];
    self.footerTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.footerTextView.textAlignment = NSTextAlignmentLeft;
    self.footerTextView.textColor = [UIColor colorWithRed:0.99 green:0.55 blue:0.31 alpha:1.00];
    self.footerTextView.font = [UIFont fontWithName:@"Avenir-Roman" size:14];
    self.footerTextView.text = @"";

//
    [self.footerTextView addSubview:footer];
//    tableView.tableFooterView = footer;
//
//    NSLog(@"Footer: %@", footer.text);

    return self.footerTextView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 200;
}

#pragma mark - CLLocationManagerDelegate
- (void)loadUserLocation {
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 500 && location.horizontalAccuracy < 500) {
            self.userLocation = location;
            [self findPizzeriasNear:self.userLocation];
            [self.locationManager stopUpdatingLocation];
            break;
        }
    }

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"Please check yoru settings to make sure you enabled sharing your location"
                                                       delegate:self
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }
}


- (void)findPizzeriasNear:(CLLocation *)location {
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"Pizzeria";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.005, 0.005));

    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSArray *mapItems = response.mapItems;

        for (MKMapItem *item in mapItems) {
            self.mainPizzeria = [[Pizzeria alloc] init];
            self.mainPizzeria.mapItem = item;
            NSString *address = [NSString stringWithFormat:@"%@ %@ %@",
                                 item.placemark.subThoroughfare,
                                 item.placemark.thoroughfare,
                                 item.placemark.locality];
            NSLog(@"Address: %@", address);
            self.mainPizzeria.locationAddress = address;
            self.mainPizzeria.locationDistance = [self.mainPizzeria.mapItem.placemark.location distanceFromLocation:location]/1000;
            self.mainPizzeria.placemark = item.placemark;
            [self.pizzeriaArray addObject:self.mainPizzeria];
        }

        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"locationDistance" ascending:YES];
        NSArray *sorted = [self.pizzeriaArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        self.pizzeriaArray = [NSMutableArray arrayWithArray:sorted];
        [self.pizzaTableView reloadData];
        self.timeToLocation = 0;
        self.directionSting = [NSMutableString string];
        [self getRoute:self.pizzeriaArray];
    }];
}

- (void)getDirectionsFromPizzeria:(MKMapItem *)first toPizzeria:(MKMapItem *)second {
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = first;
    request.destination = second;
    if (self.switchSegmentControl.selectedSegmentIndex == 0) {
        request.transportType = MKDirectionsTransportTypeWalking;
    } else {
        request.transportType = MKDirectionsTransportTypeAutomobile;
    }

    MKDirections *arrivalTime = [[MKDirections alloc] initWithRequest:request];
    [arrivalTime calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        NSArray *routes = response.routes;
        for (MKRoute *route in routes) {
            self.timeToLocation = self.timeToLocation +  (route.expectedTravelTime/60);
            NSString *message = [NSString stringWithFormat:@"Arriving at %@ in approximately %.0f minutes.\n\n", second.name, self.timeToLocation];
            NSLog(@"%@", message);
            [self.directionSting appendString:message];
            self.footerTextView.text = self.directionSting;
        }
        self.timeToLocation = self.timeToLocation + 50;
    }];
}

- (void)getRoute:(NSMutableArray *)routeArray {
    MKPlacemark *startpoint = [[MKPlacemark alloc] initWithCoordinate:self.userLocation.coordinate addressDictionary:nil];
   self.mainPizzeria.mapItem = [[MKMapItem alloc] initWithPlacemark:startpoint];

    if (routeArray.count >=5) {

        for (int i = 0; i < 5; i++) {
            Pizzeria *locationOne = routeArray[i];

            if (i != 0) {
                Pizzeria *locationTwo = routeArray[i-1];
                [self getDirectionsFromPizzeria:locationOne.mapItem toPizzeria:locationTwo.mapItem];
            } 
        }
    }
}

- (void)showRoute:(MKDirectionsResponse *)response {
    for (MKRoute *route in response.routes) {
        NSLog(@"directions: %@", route.steps);
    }
}

#pragma mark - Actions
- (IBAction)onTransportTypeSelected:(id)sender {
    self.timeToLocation = 0;
    [self.directionSting setString:@""];
    [self getRoute:self.pizzeriaArray];
    [self.pizzaTableView reloadData];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MapViewController *vc = segue.destinationViewController;
    vc.mapPizzeria = self.mainPizzeria;
    vc.userLocation = self.userLocation;
    vc.pizzerias = self.pizzeriaArray;
    vc.mapPizzeria.placemark = self.mainPizzeria.placemark;

}

@end
