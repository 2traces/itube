//
//  VertPathScrollView.h
//  tube
//
//  Created by sergey on 01.08.12.
//
//

#import <UIKit/UIKit.h>
#import "Classes/MainViewController.h"
#import "PathDrawVertView.h"

@class MainViewController;

@interface VertPathScrollView : UIScrollView <UIScrollViewDelegate,PathDrawProtocol> {
    MainViewController *myMainController;
}

@property (nonatomic,retain) MainViewController *mainController;

-(void)drawPathScrollView;

@end
