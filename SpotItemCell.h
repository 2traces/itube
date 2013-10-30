//
//  SpotItemCell.h
//  tube
//
//  Created by Alexey Starovoitov on 29/10/13.
//
//

#import <UIKit/UIKit.h>

@interface SpotItemCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *typeImage;
@property (nonatomic, retain) IBOutlet UIImageView *accessoryImage;

@end
