//
//  ActiveView.h
//  tube
//
//  Created by vasiliym on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CityMap.h"

@interface ActiveView : UIView {
    CityMap* cityMap;
}

@property (nonatomic, retain) CityMap* cityMap;

@end
