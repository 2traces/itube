//
//  SpotCommentCell.h
//  tube
//
//  Created by Alexey Starovoitov on 30/10/13.
//
//

#import <UIKit/UIKit.h>

@interface SpotCommentCell : UITableViewCell {
	NSTimer *copyPasteTimer;
    
	NSSet *copyTouches;
	UIEvent *copyEvent;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *typeImage;
@property BOOL copyActive;

@end
