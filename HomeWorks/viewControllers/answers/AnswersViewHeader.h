//
// Created by bsideup on 4/5/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000

@interface AnswersViewHeader : PSUICollectionReusableView_
#else
@interface AnswersViewHeader : UICollectionReusableView
#endif


@property(nonatomic) IBOutlet UILabel *nameLabel;
@property(nonatomic) IBOutlet UILabel *authorsLabel;
@end