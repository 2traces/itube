//
//  LeftiPadPathViewController.h
//  tube
//
//  Created by sergey on 13.08.12.
//
//

#import <UIKit/UIKit.h>
#import "PathScrollView.h"
#import "VertPathScrollView.h"

@interface LeftiPadPathViewController : UIViewController <PathScrollViewProtocol>
{
    NSTimer *timer;

}

@property (nonatomic,retain) PathScrollView *horizontalPathesScrollView;
@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,retain) VertPathScrollView *pathScrollView;

-(void)showHorizontalPathesScrollView;
-(void)showVerticalPathScrollView;
-(void)redrawPathScrollView;

@end
