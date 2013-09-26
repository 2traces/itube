//
// Created by bsideup on 4/5/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@interface AnswerViewCell : UICollectionViewCell

@property(nonatomic) IBOutlet UILabel *label;
@property(nonatomic) IBOutlet UIImageView *backgroundImage;
@property(nonatomic) IBOutlet UIImageView *itemImage;
@property(nonatomic) IBOutlet UILabel *loadingLabel;
@property(nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property(nonatomic) IBOutlet UIView *backgroundClippingView;

@end