//
//  InAppRageIAPHelper.m
//  InAppRage
//
//  Created by Ray Wenderlich on 2/28/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "TubeAppIAPHelper.h"

@implementation TubeAppIAPHelper

static TubeAppIAPHelper * _sharedHelper;

+ (TubeAppIAPHelper *) sharedHelper {
    
    if (_sharedHelper != nil) {
        return _sharedHelper;
    }
    _sharedHelper = [[TubeAppIAPHelper alloc] init];
    return _sharedHelper;
    
}

- (id)init {
    
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"maps.plist"];
    
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithContentsOfFile:path] autorelease];
    NSArray *array = [dict allKeys];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *contentIdentifier = [NSString stringWithFormat:@"%@.content", bundleIdentifier];
    
    NSSet *productIdentifiers = [[[NSSet alloc] initWithObjects:bundleIdentifier, contentIdentifier, nil] autorelease];
    
    if ((self = [super initWithProductIdentifiers:productIdentifiers])) {                
        
    }

    return self;
}

@end
