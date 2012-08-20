//
//  ReverseGeocoder.h
//  ReverseGeocoder
//
//  Created by Jeff Grimes on 8/20/12.
//  Copyright (c) 2012 Jeff Grimes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/ABPerson.h>

@protocol GeocoderProtocol <NSObject>
- (void)gotUserLocation;
- (void)gotUserLocationError;
- (void)gotUserPlacemarks;
- (void)gotUserPlacemarksError;
- (void)locationServicesDisabled;
@end

@interface ReverseGeocoder : NSObject <CLLocationManagerDelegate> {
@private
    BOOL delegateHasPlacemarks;
}

@property (nonatomic, assign) id <GeocoderProtocol> geocoderDelegate;
@property (nonatomic, retain) CLGeocoder *geocoder;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSTimer *locationTimer;
@property (nonatomic, retain) NSTimer *geocodingTimer;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSString *zipcode;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSString *administrativeArea;
@property (nonatomic, retain) NSString *subAdministrativeArea;
@property (nonatomic, retain) NSString *locality;

+ (BOOL)areLocationServicesEnabled;

- (CLAuthorizationStatus)getAuthStatus;
- (void)reverseGeocode;
- (void)stopActivity;

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status;

@end