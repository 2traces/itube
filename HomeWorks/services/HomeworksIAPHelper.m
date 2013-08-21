//
//  HomeworksIAPHelper.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "HomeworksIAPHelper.h"

@implementation HomeworksIAPHelper

+ (HomeworksIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static HomeworksIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"ru.homeworks.month",
                                      @"ru.homeworks.year",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
