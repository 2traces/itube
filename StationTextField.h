//
//  StationTextField.h
//  tube
//
//  Created by sergey on 11.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TubeStationState) {
    TubeStationStateDefault,
    TubeStationStatePath,
};

@interface StationTextField : UITextField

@property (nonatomic,assign) TubeStationState state;

@end
