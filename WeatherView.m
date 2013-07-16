//
//  WeatherView.m
//  tube
//
//  Created by Сергей on 12.07.13.
//
//

#import "WeatherView.h"
#import <QuartzCore/QuartzCore.h>
#import "WeatherHelper.h"

@implementation WeatherView

@synthesize dayOneLabel;
@synthesize dayThreeLabel;
@synthesize dayTwoLabel;

@synthesize dayOneView;
@synthesize dayTwoView;
@synthesize dayThreeView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(5, 5, 209, 58)];
        view2.backgroundColor = [UIColor whiteColor];
        view2.layer.cornerRadius = 5.0f;
        
        [self addSubview:view2];
        
        [view2 release];
        
        self.dayOneLabel = [[[UILabel alloc] initWithFrame:CGRectMake(60.0, 17.0, 65, 46)] autorelease];
        self.dayTwoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(150.0, 21.0, 55, 16)] autorelease];
        self.dayThreeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(150.0, 37.0, 55, 16)] autorelease];
        
        self.dayOneLabel.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1];
        self.dayTwoLabel.textColor = [UIColor colorWithRed:0.53 green:0.53 blue:0.53 alpha:1];
        self.dayThreeLabel.textColor = [UIColor colorWithRed:0.53 green:0.53 blue:0.53 alpha:1];
        
        self.dayOneLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:40.0f];
        self.dayTwoLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14.0f];
        self.dayThreeLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14.0f];
        
        [self addSubview:self.dayOneLabel];
        [self addSubview:self.dayTwoLabel];
        [self addSubview:self.dayThreeLabel];
        
        self.dayOneView = [[[UIImageView alloc] initWithFrame:CGRectMake(13, 10, 46, 48)] autorelease];
        self.dayTwoView = [[[UIImageView alloc] initWithFrame:CGRectMake(128, 18, 15, 16)] autorelease];
        self.dayThreeView = [[[UIImageView alloc] initWithFrame:CGRectMake(128, 34, 15, 16)] autorelease];

        [self addSubview:self.dayOneView];
        [self addSubview:self.dayTwoView];
        [self addSubview:self.dayThreeView];

    }
    
    return self;
}

-(void)layoutSubviews
{
    NSMutableString *oneText=nil;
    NSMutableString *twoText=nil;
    NSMutableString *threeText=nil;
    
    UIImage *oneImage;
    UIImage *twoImage;
    UIImage *threeImage;
    
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    [weekday setDateFormat: @"EEE"];
    
    NSDictionary *dict = [[WeatherHelper sharedHelper] getWeatherInformation];
    
    if ([dict count]>2) {
        
        NSArray *array = [dict allKeys];
        NSArray *sortedKeys = [array sortedArrayUsingSelector: @selector(compare:)];

        NSInteger oneDayTemp = [[[dict objectForKey:[sortedKeys objectAtIndex:0]] objectForKey:@"temperature"] integerValue];
        NSInteger twoDayTemp = [[[dict objectForKey:[sortedKeys objectAtIndex:1]] objectForKey:@"temperature"] integerValue];
        NSInteger threeDayTemp = [[[dict objectForKey:[sortedKeys objectAtIndex:1]] objectForKey:@"temperature"] integerValue];
        
        NSString *twoDayWeekday = [weekday stringFromDate:[sortedKeys objectAtIndex:1]];
        NSString *threeDayWeekday = [weekday stringFromDate:[sortedKeys objectAtIndex:2]];
        
        oneText = [NSMutableString stringWithFormat:@"%d",oneDayTemp];
        twoText = [NSMutableString stringWithFormat:@"%@, %d",twoDayWeekday,twoDayTemp];
        threeText = [NSMutableString stringWithFormat:@"%@, %d",threeDayWeekday,threeDayTemp];
        
        oneImage = [self imageForWeatherCode:[[dict objectForKey:[sortedKeys objectAtIndex:0]] objectForKey:@"number"]];
        twoImage = [self imageForWeatherCode:[[dict objectForKey:[sortedKeys objectAtIndex:1]] objectForKey:@"number"]];
        threeImage = [self imageForWeatherCode:[[dict objectForKey:[sortedKeys objectAtIndex:2]] objectForKey:@"number"]];

    } else {
        
        oneText = [NSMutableString stringWithString:@"--"];
        twoText = [NSMutableString stringWithString:@"--"];
        threeText = [NSMutableString stringWithString:@"--"];
        
        oneImage = nil;
        twoImage = nil;
        threeImage = nil;
        
    }
    
    [weekday release];
    
    [oneText appendString:@"°"];
    [twoText appendString:@"°"];
    [threeText appendString:@"°"];

    dayOneLabel.text = oneText;
    dayTwoLabel.text = twoText;
    dayThreeLabel.text = threeText;
    
    dayOneView.image = oneImage;
    dayTwoView.image = twoImage;
    dayThreeView.image = threeImage;

}

-(UIImage*)imageForWeatherCode:(NSNumber*)code
{
    NSInteger intCode = [code integerValue];
    switch (intCode) {
        case 200:
        case 201:
        case 202:
        case 210:
        case 211:
        case 212:
        case 221:
        case 230:
        case 231:
        case 232:
            return [UIImage imageNamed:@"today_thunder"];
            break;
            
        case 300:
        case 301:
        case 302:
        case 310:
        case 311:
        case 312:
        case 321:

        case 500:
        case 501:
        case 502:
        case 503:
        case 504:
        case 511:
        case 520:
        case 521:
        case 522:

        case 600:
        case 601:
        case 602:
        case 611:
        case 621:

        case 701:
        case 711:
        case 721:
        case 731:
        case 741:

            return [UIImage imageNamed:@"today_rain"];
            break;
                    
        case 800:
        case 801:
            return [UIImage imageNamed:@"today_sun"];
            break;

        case 802:
        case 803:
        case 804:
            return [UIImage imageNamed:@"today_cloud"];
            break;

        default:
            return nil;
            break;
            
    }
    
    return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)dealloc
{
    [dayOneLabel release];
    [dayTwoLabel release];
    [dayThreeLabel release];
    [dayOneView release];
    [dayTwoView release];
    [dayThreeView release];

    [super dealloc];
}

@end
