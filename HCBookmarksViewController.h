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

@end



@interface HCBookmarksViewController : UIViewController <BookmarkDelegate> {
    NSMutableArray *items;
    NSArray *places;
    UIScrollView *scrollView;
}

@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) NSArray *places;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (IBAction)close:(id)sender;

@end
