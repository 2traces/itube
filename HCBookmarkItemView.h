//
//  HCBookmarkItemView.h
//  tube
//
//  Created by Alexey Starovoitov on 14/11/12.
//
//

#import <UIKit/UIKit.h>
#import "HCBookmarksViewController.h"

@interface HCBookmarkItemView : UIView {
    UIImageView *imageView;
    UIImageView *imageInfoBg;
    UITextView *textView;
    UILabel *labelPlaceName;
    UILabel *labelPlaceDistance;
    UIButton *buttonRemoveFromBookmarks;
    UIView *infoContainer;
    id<BookmarkDelegate> bookmarkDelegate;
}

- (void) setImage:(UIImage*)image text:(NSString*)text placeName:(NSString*)name placeDistance:(NSString*)distance;
- (IBAction)removeItemFromFavorites:(id)sender;

@property (nonatomic, retain) id<BookmarkDelegate> bookmarkDelegate;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIImageView *imageInfoBg;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UILabel *labelPlaceName;
@property (nonatomic, retain) IBOutlet UILabel *labelPlaceDistance;
@property (nonatomic, retain) IBOutlet UIButton *buttonRemoveFromBookmarks;
@property (nonatomic, retain) IBOutlet UIView *infoContainer;

@end
