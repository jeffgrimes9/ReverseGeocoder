//
//  ViewController.m
//  ReverseGeocoder
//
//  Created by Jeff Grimes on 8/20/12.
//  Copyright (c) 2012 Jeff Grimes. All rights reserved.
//

#import "ViewController.h"

NSString *errorStringGeneral = @"Failed to find user's location.";
NSString *errorStringLocationServicesDisabled = @"Location Services disabled.";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.errorLabel.text = @"";
    self.geocoder = [[[ReverseGeocoder alloc] init] autorelease];
    self.geocoder.geocoderDelegate = self;
}

- (IBAction)geocodeButtonTapped {
    CLAuthorizationStatus authStatus = [self.geocoder getAuthStatus];
    if (authStatus == kCLAuthorizationStatusNotDetermined || authStatus == kCLAuthorizationStatusAuthorized) {
        [self.spinner startAnimating];
        [self.geocoder reverseGeocode];
    } else {
        [self locationServicesDisabled];
    }
}

- (void)gotUserLocation {
    [self updateFieldsWithError:NO];
}

- (void)gotUserLocationError {
    [self updateFieldsWithError:YES];
}

- (void)gotUserPlacemarks {
    [self updateFieldsWithError:NO];
    [self.spinner stopAnimating];
}

- (void)gotUserPlacemarksError {
    [self updateFieldsWithError:YES];
}

- (void)locationServicesDisabled {
    self.errorLabel.text = errorStringLocationServicesDisabled;
    self.field0.text = @"";
    self.field1.text = @"";
    self.field2.text = @"";
    self.field3.text = @"";
    self.field4.text = @"";
    self.field5.text = @"";
    self.field6.text = @"";
    [self.spinner stopAnimating];
}

- (void)updateFieldsWithError:(BOOL)error {
    if (error) {
        self.errorLabel.text = errorStringGeneral;
    } else {
        self.errorLabel.text = @"";
        self.field0.text = [NSString stringWithFormat:@"%f", self.geocoder.latitude];
        self.field1.text = [NSString stringWithFormat:@"%f", self.geocoder.longitude];
        self.field2.text = self.geocoder.address;
        self.field3.text = self.geocoder.city;
        self.field4.text = self.geocoder.state;
        self.field5.text = self.geocoder.zipcode;
        self.field6.text = self.geocoder.country;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.geocoder = nil;
    self.spinner = nil;
    self.field0 = nil;
    self.field1 = nil;
    self.field2 = nil;
    self.field3 = nil;
    self.field4 = nil;
    self.field5 = nil;
    self.field6 = nil;
    self.errorLabel = nil;
    [super dealloc];
}

@end