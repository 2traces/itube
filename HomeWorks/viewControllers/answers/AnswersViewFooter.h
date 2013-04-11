//
// Created by bsideup on 4/9/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000

@interface AnswersViewFooter : PSUICollectionReusableView_
#else
@interface AnswersViewFooter : UICollectionReusableView
#endif
@property (nonatomic) IBOutlet UIImageView *backgroundImage;

@end