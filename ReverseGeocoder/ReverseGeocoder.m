//
//  ReverseGeocoder.m
//  ReverseGeocoder
//
//  Created by Jeff Grimes on 8/20/12.
//  Copyright (c) 2012 Jeff Grimes. All rights reserved.
//

#import "ReverseGeocoder.h"

@implementation ReverseGeocoder

static ReverseGeocoder *sharedInstance = nil;
const int locationTimeLimit = 8;  // max time limit for getting location
const int geocodingTimeLimit = 8; // max time limit for reverse-geocoding location
const int staleCacheSeconds = 5;  // the lower this value, the pickier you are about cached location data. a typical value is between 5 and 10.

+ (id)sharedInstance {
    @synchronized([ReverseGeocoder class]) {
        if (sharedInstance == nil) {
            sharedInstance = [[ReverseGeocoder alloc] init];
        }
    }
    return sharedInstance;
}

+ (BOOL)areLocationServicesEnabled {
    return [CLLocationManager locationServicesEnabled];
}

- (id)init {
    if (self = [super init]) {
        self.geocoder = [[[CLGeocoder alloc] init] autorelease];
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationTimer = [[[NSTimer alloc] init] autorelease];
        self.geocodingTimer = [[[NSTimer alloc] init] autorelease];
        delegateHasPlacemarks = NO;
    }
    return self;
}

- (void)callGotUserLocation {
    if ([self.geocoderDelegate respondsToSelector:@selector(gotUserLocation)]) {
        [self.geocoderDelegate gotUserLocation];
    } else {
        NSLog(@"delegate does not implement gotUserLocation");
    }
}

- (void)callGotUserLocationError {
    if (delegateHasPlacemarks) {
        return;
    }
    if ([self.geocoderDelegate respondsToSelector:@selector(gotUserLocationError)]) {
        [self.geocoderDelegate gotUserLocationError];
    } else {
        NSLog(@"delegate does not implement gotUserLocationError");
    }
}

- (void)callGotUserPlacemarks {
    if ([self.geocoderDelegate respondsToSelector:@selector(gotUserPlacemarks)]) {
        [self.geocoderDelegate gotUserPlacemarks];
    } else {
        NSLog(@"delegate does not implement gotUserPlacemarks");
    }
}

- (void)callGotUserPlacemarksError {
    if (delegateHasPlacemarks) {
        return;
    }
    if ([self.geocoderDelegate respondsToSelector:@selector(gotUserPlacemarksError)]) {
        [self.geocoderDelegate gotUserPlacemarksError];
    } else {
        NSLog(@"delegate does not implement gotUserPlacemarksError");
    }
}

- (void)callLocationServicesDisabled {
    if ([self.geocoderDelegate respondsToSelector:@selector(locationServicesDisabled)]) {
        [self.geocoderDelegate locationServicesDisabled];
    } else {
        NSLog(@"delegate does not implement locationServicesDisabled");
    }
}

- (CLAuthorizationStatus)getAuthStatus {
    return [CLLocationManager authorizationStatus];
}

- (void)reverseGeocode {
    [self.locationManager startUpdatingLocation];
}

- (void)stopActivity {
    delegateHasPlacemarks = YES;
    [self.locationManager stopUpdatingLocation];
}

- (void)geocodeLocation:(CLLocation *)location {
    self.geocodingTimer = [NSTimer scheduledTimerWithTimeInterval:geocodingTimeLimit target:self selector:@selector(callGotUserPlacemarksError) userInfo:nil repeats:NO];
    [self.geocoder reverseGeocodeLocation: location completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         [self.geocodingTimer invalidate];
         if (error == nil) {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             
             self.address = [[placemark addressDictionary] objectForKey:(NSString *)kABPersonAddressStreetKey];
             self.city = [[placemark addressDictionary] objectForKey:(NSString *)kABPersonAddressCityKey];
             self.state = [[placemark addressDictionary] objectForKey:(NSString *)kABPersonAddressStateKey];
             self.zipcode = [placemark postalCode];
             self.country = [placemark country];
             // you can also use the same format to fetch administrative area, sub-administrative area, and locality.
             
             [self callGotUserPlacemarks];
         } else {
             [self callGotUserPlacemarksError];
         }
     }];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSDate *eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    BOOL isLocationFresh = abs(howRecent) < staleCacheSeconds;
    if (isLocationFresh) {
        [self.locationManager stopUpdatingLocation];
        [self.locationTimer invalidate];
        self.latitude = self.locationManager.location.coordinate.latitude;
        self.longitude = self.locationManager.location.coordinate.longitude;
        [self geocodeLocation:self.locationManager.location];
        NSLog(@"obtained fresh location");
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"location manager failed");
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [self callLocationServicesDisabled];
    } else {
        [self callGotUserLocationError];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied) {
        NSLog(@"user disabled location services");
        [self callLocationServicesDisabled];
    } else if (status == kCLAuthorizationStatusAuthorized) {
        NSLog(@"user enabled location services");
        self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:locationTimeLimit target:self selector:@selector(callGotUserLocationError) userInfo:nil repeats:NO];
    }
}

- (void)dealloc {
    self.geocoderDelegate = nil;
    self.geocoder = nil;
    self.locationManager = nil;
    self.locationTimer = nil;
    self.geocodingTimer = nil;
    self.country = nil;
    self.zipcode = nil;
    [super dealloc];
}

@end