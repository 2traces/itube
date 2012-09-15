//
//  CustomPopoverBackgroundView.h
//  tube
//
//  Created by sergey on 27.08.12.
//
//

#import <UIKit/UIPopoverBackgroundView.h>   

@interface CustomPopoverBackgroundView : UIPopoverBackgroundView {
    UIImageView *_borderImageView;
    UIImageView *_arrowView;
    CGFloat _arrowOffset;
    UIPopoverArrowDirection _arrowDirection; }
@end
