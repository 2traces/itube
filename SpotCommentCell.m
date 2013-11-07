//
//  SpotCommentCell.m
//  tube
//
//  Created by Alexey Starovoitov on 30/10/13.
//
//

#import "SpotCommentCell.h"

@implementation SpotCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)showCopyPasteView:(NSTimer*)theTimer
{
	if ([self becomeFirstResponder]) {
		CGRect frame = self.frame;
		
		//show the "copy" menu
		UIMenuController *theMenu = [UIMenuController sharedMenuController];
		[theMenu setTargetRect:frame inView:self.superview];
		[theMenu setMenuVisible:YES animated:YES];
		self.copyActive = YES;
        
		//add blue background
		[self setHighlighted:YES animated:NO];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHideMenu) name:UIMenuControllerDidHideMenuNotification object:nil];
	}
}

-(void)didHideMenu
{
	//cancel the touches, otherwise the tableview will behave weird with the next touch
	[super touchesCancelled:copyTouches withEvent:copyEvent];
	
	self.copyActive = NO;
	
	//remove blue background
	[self setHighlighted:NO animated:NO];
    
	//I don't think this is needed
	//[self setSelected:NO animated:NO];
	
	//remove the observer from the NSNotificationCenter, you only want to call didHideMenu once
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
}


/*
 * We need to call touchesCancelled in didHideMenu otherwise the tableview will not respond to the next touch.
 * But by doing so we get a flicker when switching between cells with the copying menu.
 * If you want to see this effect: just comment out this function
 */
- (void)setHighlighted:(BOOL)newHighlighted animated:(BOOL)animated
{
	if(![copyPasteTimer isValid] && !newHighlighted){
		[super setHighlighted:newHighlighted animated:animated];
	} else if([copyPasteTimer isValid] && newHighlighted){
		[super setHighlighted:newHighlighted animated:animated];
	}
}

//needed for the menu
- (BOOL)canBecomeFirstResponder {
    return YES;
}

//what to copy
- (void)copy:(id)sender {
	UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
	
	if(self.subtitleLabel.text && ![self.subtitleLabel.text isEqual:@""]){
		[gpBoard setString:self.subtitleLabel.text];
	} 
    
}

//what this cell can do: only copy
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
	if (action == @selector(cut:))
		return NO;
	else if (action == @selector(copy:))
		return YES;
	else if (action == @selector(paste:))
		return NO;
	else if (action == @selector(select:) || action == @selector(selectAll:))
		return NO;
	else return [super canPerformAction:action withSender:sender];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[copyPasteTimer release];
	copyPasteTimer = [[NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(showCopyPasteView:) userInfo:nil repeats:NO] retain];
	
	[super touchesBegan:touches withEvent:event];
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//weird things start to happen without this check
	if(!self.copyActive) {
		[super touchesMoved:touches withEvent:event];
	}
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[copyPasteTimer invalidate];
    
	if(self.copyActive){
		//don't call the didHideMenu because the cell is already unhighlighted and the touches will also be cancelled.
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		
		//hide the "copy" menu
		UIMenuController *theMenu = [UIMenuController sharedMenuController];
		[theMenu setMenuVisible:NO animated:YES];
	}
	
	[super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[copyPasteTimer invalidate];
    
	if(!self.copyActive){
		[super touchesEnded:touches withEvent:event];
	} else {
		//remember where de touches ended so that we can cancel them when the "copy" menu hides.
		[copyTouches release];
		copyTouches = [touches retain];
		
		[copyEvent release];
		copyEvent = [event retain];
	}
}

- (void)dealloc {
	[copyTouches release];
	[copyEvent release];
	[copyPasteTimer release];
	
    [super dealloc];
}


@end
