//
//  PhotosViewController.h
//  tube
//
//  Created by Alexey on 5/11/12.
//
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"

@interface PhotosViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    UIScrollView *scrollPhotos;
    UIButton *buttonCategories;
    UIView *disappearingView;
    UIView *panelView;
    NSInteger currentPage;
    UILabel *placeNameHeader;
    UILabel *placeNamePanel;
    UILabel *placeDescription;
    UIButton *btAddToFavorites;
    UIButton *btShowHideBookmarks;
}

@property (nonatomic, retain) IBOutlet UILabel *placeNameHeader;
@property (nonatomic, retain) IBOutlet UILabel *placeNamePanel;
@property (nonatomic, retain) IBOutlet UILabel *placeDescription;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollPhotos;
@property (nonatomic, retain) IBOutlet UIButton *btAddToFavorites;
@property (nonatomic, retain) IBOutlet UIButton *buttonCategories;
@property (nonatomic, retain) IBOutlet UIButton *btShowHideBookmarks;
@property (nonatomic, retain) IBOutlet UIView *disappearingView;
@property (nonatomic, retain) IBOutlet UIView *panelView;
@property (nonatomic, assign) id<NavigationDelegate> navigationDelegate;
@property (nonatomic, retain) NSArray *currentPlaces;
@property (nonatomic, retain) NSArray *currentPhotos;

- (IBAction)showCategories:(id)sender;
- (IBAction)showHidePhotos:(id)sender;
- (IBAction)showBookmarks:(id)sender;
- (IBAction)addToFavorites:(id)sender;


- (void) loadPlaces:(NSArray*)places;

@end
