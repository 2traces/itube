//
//  PathBarView.m
//  tube
//
//  Created by sergey on 31.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PathBarView.h"
#import "PathDrawView.h"
#import "CityMap.h"
#import "tubeAppDelegate.h"

@implementation PathBarView

- (id)initWithFrame:(CGRect)frame path:(NSMutableArray*)thisPath number:(int)number overall:(int)overall
{
    self = [super initWithFrame:frame];
    if (self) {
 
        int page = frame.origin.x/320.0;
        
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)];
        bgView.tag=5000+page;
        bgView.image = [UIImage imageNamed:@"lower_path_bg.png"]; //lower_path_bg toolbar_bg
        [self addSubview:bgView];
        [bgView release];
        
        NSString *fileName = [NSString stringWithFormat:@"n%d.png",number+1];
        UIImageView *pathNumberView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];
        pathNumberView.frame = CGRectMake(8,4,24,32);
        [self addSubview:pathNumberView];
        [pathNumberView release];
        
        UILabel *over = [[UILabel alloc] init];
        over.text=[NSString stringWithFormat:@"%d",overall];        
        over.backgroundColor = [UIColor clearColor];
        over.font = [UIFont fontWithName:@"MyriadPro-Regular" size:9.0];
        over.textColor = [UIColor whiteColor];
        over.frame=CGRectMake(23, 9, 10, 10); 
        [self addSubview:over];
        [over release];

        
        UIImageView *clockView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock.png"]];
        clockView.frame = CGRectMake(37, 4, 14, 14);
        clockView.tag=6400+page;
        [self addSubview:clockView];
        [clockView release];
        
        UIImageView *flagView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flag.png"]];
        flagView.frame = CGRectMake(244,5,14,14);
        flagView.tag=6500+page;
        [self addSubview:flagView];
        [flagView release];
        
        NSInteger travelTime = [self dsGetTravelTime:thisPath];
        UILabel *travelTimeLabel = [[UILabel alloc] init];
        travelTimeLabel.text=[NSString stringWithFormat:@"%d %@",travelTime,NSLocalizedString(@"minutes", @"minutes")];        
        travelTimeLabel.backgroundColor = [UIColor clearColor];
        travelTimeLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:13.0];
        travelTimeLabel.textColor = [UIColor darkGrayColor];
        travelTimeLabel.shadowColor = [UIColor whiteColor];
        travelTimeLabel.shadowOffset = CGSizeMake(0, 1);
        travelTimeLabel.frame=CGRectMake(52.0, 6, 65, 15); 
        travelTimeLabel.tag=6000+page;
        [self addSubview:travelTimeLabel];
        [travelTimeLabel release];
        
        UILabel *arrivalTimeLabel = [[UILabel alloc] init];
        arrivalTimeLabel.backgroundColor = [UIColor clearColor];
        arrivalTimeLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:13.0];
        arrivalTimeLabel.frame=CGRectMake(256.0, 7, 54, 15); 
        arrivalTimeLabel.shadowOffset = CGSizeMake(0, 1);
        arrivalTimeLabel.shadowColor = [UIColor whiteColor];
        arrivalTimeLabel.tag=7000+page;
        arrivalTimeLabel.textAlignment=UITextAlignmentRight;
        [self addSubview:arrivalTimeLabel];
        [arrivalTimeLabel release];
        
        PathDrawView *drawView = [[PathDrawView alloc] initWithFrame:CGRectMake(0, 0, 320, 40) path:(NSMutableArray*)thisPath];
        drawView.tag =10000+page;
        [self addSubview:drawView];
        [drawView release];

        NSString *arrivalTime = [self getArrivalTimeFromNow:travelTime];
        CGSize atSize = [arrivalTime sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:13.0]];
        CGRect labelRect = [(UILabel*)[self viewWithTag:7000+page] frame];
        CGFloat labelStart = 310.0-atSize.width-2.0;
        [(UILabel*)[self viewWithTag:7000+page] setFrame:CGRectMake(labelStart, labelRect.origin.y, atSize.width+2.0, labelRect.size.height)];
        [(UILabel*)[self viewWithTag:7000+page] setText:[NSString stringWithFormat:@"%@",arrivalTime]];
        
        CGRect flagRect = [(UILabel*)[self viewWithTag:6500+page] frame];
        [(UIImageView*)[self viewWithTag:6500+page] setFrame:CGRectMake(labelStart-flagRect.size.width-2.0, flagRect.origin.y, flagRect.size.width, flagRect.size.height)];
        
        if (IS_IPAD) {
            
            CGSize dateSize = [arrivalTime sizeWithFont:[UIFont fontWithName:@"MyriadPro-Regular" size:16.0]];
            
            [[self viewWithTag:10000+page] removeFromSuperview];
            [[self viewWithTag:6400+page] setFrame:CGRectMake(37, 10, 18, 18)];
            [[self viewWithTag:6500+page] setFrame:CGRectMake(320.0-10.0-dateSize.width-5-26, 10, 18, 18)];

            [[self viewWithTag:6000+page] setFrame:CGRectMake(63, 12, 90, 20)];
            [(UILabel*)[self viewWithTag:6000+page] setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:16.0]];

//            [[self viewWithTag:7000+page] setFrame:CGRectMake(196, 12, 90, 20)];
            [[self viewWithTag:7000+page] setFrame:CGRectMake(320.0-10.0-dateSize.width-5 , 12 , dateSize.width+5 , 20)];
            [(UILabel*)[self viewWithTag:7000+page] setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:16.0]];
            [(UILabel*)[self viewWithTag:7000+page] setTextAlignment:UITextAlignmentLeft];
        }
    }

    return self;
}

-(NSString*)getArrivalTimeFromNow:(NSInteger)time
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];

    if ([appDelegate.cityMap.pathTimesList count]>1) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        NSString *arrivalTime = [formatter stringFromDate:[appDelegate.cityMap.pathTimesList lastObject]];
        [formatter release];
        return arrivalTime;    
    }

    NSDate *newDate = [NSDate dateWithTimeIntervalSinceNow:time*60.0]; 
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    
    NSString *arrivalTime = [formatter stringFromDate:newDate];
    
    [formatter release];
    
    return arrivalTime;
}


-(NSInteger)dsGetTravelTime:(NSArray*)thisPath
{
    tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
 
    if ([appDelegate.cityMap.pathTimesList count]>1) {
        NSTimeInterval timeInterval = [[appDelegate.cityMap.pathTimesList lastObject] timeIntervalSinceNow];
        NSInteger transferTimeS = ceil((float)timeInterval/60.0);
        if(transferTimeS < 0) transferTimeS += 60*24;
        return transferTimeS;    
    }

    NSArray *path = thisPath;
    int objectNum = [path count];
    
    NSInteger transferTime=0;
    NSInteger lineTime=0;
    
    for (int i=0; i<objectNum; i++) {
        if ([[path objectAtIndex:i] isKindOfClass:[Segment class]]) {
            Segment *segment = (Segment*)[path objectAtIndex:i];
            lineTime+=[segment driving];
        } else if ([[path objectAtIndex:i] isKindOfClass:[Transfer class]]) {
            transferTime+=[(Transfer*)[path objectAtIndex:i] time];
        }
    }
    
    return lineTime+transferTime;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
}
 */

@end
