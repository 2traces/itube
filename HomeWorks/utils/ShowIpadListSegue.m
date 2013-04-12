//
// Created by bsideup on 4/12/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ShowIpadListSegue.h"
#import "FRLayeredNavigationController.h"
#import "FRLayerController.h"

@interface FRLayerController(setMaximumWidth)

@property (nonatomic, readwrite) BOOL maximumWidth;
@end


@interface FRLayeredNavigationController(layerControllerOf)
- (FRLayerController *)layerControllerOf:(UIViewController *)vc;
@end

@implementation ShowIpadListSegue
{

}

- (void)perform
{
	FRLayeredNavigationController *layeredNavigationController = [[FRLayeredNavigationController alloc] initWithRootViewController:self.destinationViewController];

	[layeredNavigationController layerControllerOf:self.destinationViewController].maximumWidth = YES;

	layeredNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

	[self.sourceViewController presentModalViewController:layeredNavigationController animated:YES];
}
@end