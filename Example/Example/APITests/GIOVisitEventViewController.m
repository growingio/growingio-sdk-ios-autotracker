//
//  GIOVisitEventViewController.m
//  GrowingExample
//
//  Created by GrowingIO on 2020/2/28.
//  Copyright © 2020 GrowingIO. All rights reserved.
//

#import "GIOVisitEventViewController.h"

@import MapKit;

@interface GIOVisitEventViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *setLocationButton;
@property (weak, nonatomic) IBOutlet UILabel *locationDisplayLabel;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;

@end

@implementation GIOVisitEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"visitor 事件";

    [self setup];
}

- (void)setup {
    if (![CLLocationManager locationServicesEnabled]) {
        self.locationDisplayLabel.text = @"请在设置->隐私中打开定位服务";
    }

    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        [self.locationManager requestWhenInUseAuthorization];
    }

    MKCoordinateSpan span = MKCoordinateSpanMake(0.021251, 0.016093);

    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    [self.mapView setRegion:MKCoordinateRegionMake(self.mapView.userLocation.coordinate, span) animated:YES];
}

- (IBAction)setLocationBtnClick:(UIButton *)sender {
//    [Growing setLocation:self.location.coordinate.latitude longitude:self.location.coordinate.longitude];
}

- (IBAction)clearLocationBtnClick:(UIButton *)sender {
//    [Growing cleanLocation];
}

#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (userLocation) {
        self.setLocationButton.enabled = YES;
        self.location = userLocation.location;

        self.locationDisplayLabel.text =
            [NSString stringWithFormat:@"lat: %f lng: %f", userLocation.location.coordinate.latitude,
                                       userLocation.location.coordinate.longitude];

        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude,
                                                                     userLocation.location.coordinate.longitude)];
    }
}

#pragma mark lazy load

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

@end
