//
//  PathDrawView.h
//  tube
//
//  Created by sergey on 31.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PathDrawProtocol;
@class Station;

@interface PathDrawView : UIView {
    NSMutableDictionary *pathInfo; 
    NSInteger travelTime;
    NSMutableArray *points;
    
    id <PathDrawProtocol> delegate;
}

@property (nonatomic, retain) NSMutableDictionary *pathInfo;
@property (nonatomic, assign) NSInteger travelTime;
@property (nonatomic, assign) id <PathDrawProtocol> delegate;

-(void) drawCircleInRect:(CGRect)circleRect color:(UIColor*)color context:(CGContextRef)c;

@end

@protocol PathDrawProtocol

-(NSInteger)dsGetTravelTime;
-(NSArray*)dsGetLinesColorArray;
-(NSArray*)dsGetLinesTimeArray;
-(NSArray*)dsGetStationsArray;
-(NSInteger)dsGetExitForStation:(Station *)station1 toStation:(Station *)station2;
-(BOOL)dsIsStartingTransfer;
-(BOOL)dsIsEndingTransfer;



@end