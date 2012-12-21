//
//  HCBookmarksViewController.h
//  tube
//
//  Created by Alexey on 14/11/12.
//
//

#import <UIKit/UIKit.h>


@protocol BookmarkDelegate <NSObject>

- (void) removeFromFavoritesItemWithIndex:(NSInteger)index;
- (void) showMapForItemWithIndex:(NSInteger)index;

@end



@interface HCBookmarksViewController : UIViewController <BookmarkDelegate> {
    NSMutableArray *items;
    NSArray *places;
    UIScrollView *scrollView;
    UIImageView *emptyPlaceholder;
}

@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) NSArray *places;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIImageView *emptyPlaceholder;


- (IBAction)close:(id)sender;

@end
