//
//  DirectionView.h
//  tube
//
//  Created by Alexey Starovoitov on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainView.h"

@interface DirectionView : UIView {
    UIButton *button;
    UIImageView *arrow;
    CGPoint pinCoordinates;
    NSInteger pinID;
    MainView *mainView;
}

@property (nonatomic, retain) UIButton *button;
@property (nonatomic, retain) UIImageView *arrow;
@property (nonatomic, assign) CGPoint pinCoordinates;
@property (nonatomic, assign) NSInteger pinID;

- (id)initWithPinCoordinates:(CGPoint)coordinates pinID:(NSInteger)pindId mainView:(MainView*)mainView;
- (void)setRadialOffset:(CGFloat)offset;

@end
