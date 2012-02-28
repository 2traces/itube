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
    
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"maps.plist"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSArray *array = [dict allKeys];
    
    NSSet *productIdentifiers = [[NSSet alloc] initWithArray:array];    
    
    if ((self = [super initWithProductIdentifiers:productIdentifiers])) {                
        
    }

    return self;
    
}


@end
