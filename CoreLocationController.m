//
//  CoreLocationController.m
//  CoreLocationDemo
//
//  Created by Nicholas Vellios on 8/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import "CoreLocationController.h"


@implementation CoreLocationController

@synthesize locMgr, delegate;

- (id)init {
	self = [super init];
	
	if(self != nil) {
		self.locMgr = [[[CLLocationManager alloc] init] autorelease];
		self.locMgr.delegate = self;
		//[self.locMgr startUpdatingLocation];
	}
	
	return self;
}

#ifdef TARGET_IPHONE_SIMULATOR 

-(void)startUpdatingLocation {
    CLLocation *powellsTech = [[[CLLocation alloc] initWithLatitude:45.523450 longitude:-122.678897] autorelease];
    [self.delegate locationManager:locMgr
               didUpdateToLocation:powellsTech
                      fromLocation:powellsTech];    
}


#endif // TARGET_IPHONE_SIMULATOR

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	if([self.delegate conformsToProtocol:@protocol(CoreLocationControllerDelegate)]) {
		[self.delegate locationUpdate:newLocation];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	if([self.delegate conformsToProtocol:@protocol(CoreLocationControllerDelegate)]) {
		[self.delegate locationError:error];
	}
}

- (void)dealloc {
	[locMgr release];
	[super dealloc];
}

@end

