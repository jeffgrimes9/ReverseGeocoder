//
//  ViewController.h
//  ReverseGeocoder
//
//  Created by Jeff Grimes on 8/20/12.
//  Copyright (c) 2012 Jeff Grimes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReverseGeocoder.h"

@interface ViewController : UIViewController <GeocoderProtocol>

@property (nonatomic, retain) ReverseGeocoder *geocoder;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UITextField *field0;
@property (nonatomic, retain) IBOutlet UITextField *field1;
@property (nonatomic, retain) IBOutlet UITextField *field2;
@property (nonatomic, retain) IBOutlet UITextField *field3;
@property (nonatomic, retain) IBOutlet UITextField *field4;
@property (nonatomic, retain) IBOutlet UITextField *field5;
@property (nonatomic, retain) IBOutlet UITextField *field6;
@property (nonatomic, retain) IBOutlet UILabel *errorLabel;

- (IBAction)geocodeButtonTapped;

// ReverseGeocoder delegate methods
- (void)gotUserLocation;
- (void)gotUserLocationError;
- (void)gotUserPlacemarks;
- (void)gotUserPlacemarksError;
- (void)locationServicesDisabled;

@end