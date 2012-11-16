//
//  ReaderItemViewController.h
//  tube
//
//  Created by Alexey Starovoitov on 16/11/12.
//
//

#import <UIKit/UIKit.h>

@interface ReaderItemViewController : UIViewController {
    UIScrollView *scrollView;
    UITextView *textView;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@end
