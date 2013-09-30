//
// Created by bsideup on 4/5/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "AnswersViewHeader.h"


@implementation AnswersViewHeader
{

}

- (void) hideShowBuyView {
    CGRect frame = self.buyView.frame;
    if (frame.origin.y == 0) {
        frame.origin.y = -151;
    }
    else {
        frame.origin.y = 0;
    }
    
//    [UIView animateWithDuration:0.5f animations:^{
        self.buyView.frame = frame;
        self.buyButton.alpha = 0;
//    }];
    
}

@end