//
//  ReaderViewController.h
//  tube
//
//  Created by Alexey Starovoitov on 16/11/12.
//
//

#import <UIKit/UIKit.h>

@interface ReaderViewController : UIViewController <UIScrollViewDelegate> {
    UIButton *btBack;
    UIButton *btStar;
    UILabel *lbHeader;
    UIScrollView *scrollView;
    UIPageControl *pageControl;
    NSInteger currentPage;
    
}

- (id) initWithReaderItems:(NSArray*)_items currentItemIndex:(NSInteger)currentItemIndex;

@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) NSMutableArray *itemViews;
@property (nonatomic, retain) IBOutlet UIButton *btBack;
@property (nonatomic, retain) IBOutlet UIButton *btStar;
@property (nonatomic, retain) IBOutlet UILabel *lbHeader;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;

- (IBAction)back:(id)sender;
- (IBAction)star:(id)sender;

@end
