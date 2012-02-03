//
//  PathDrawVertView.h
//  tube
//
//  Created by sergey on 02.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>

@protocol PathDrawProtocol;

@interface PathDrawVertView : UIView {
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

