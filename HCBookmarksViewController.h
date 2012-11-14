//
//  HCBookmarksViewController.h
//  tube
//
//  Created by Alexey Starovoitov on 14/11/12.
//
//

#import <UIKit/UIKit.h>

@interface HCBookmarksViewController : UIViewController {
    NSMutableArray *items;
    UIScrollView *scrollView;
}

@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (IBAction)close:(id)sender;

@end
