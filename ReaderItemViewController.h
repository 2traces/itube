//
//  ReaderItemViewController.h
//  tube
//
//  Created by Alexey Starovoitov on 16/11/12.
//
//

#import <UIKit/UIKit.h>
#import "ManagedObjects.h"

@interface ReaderItemViewController : UIViewController {
    UIScrollView *scrollPhotos;
    UITextView *textView;
    MPlace *place;
}

- (id)initWithPlaceObject:(MPlace*)_place;

@property (nonatomic, retain) MPlace *place;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollPhotos;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@end
