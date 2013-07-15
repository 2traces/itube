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
        
        self.dayOneLabel = [[[UILabel alloc] initWithFrame:CGRectMake(60.0, 17.0, 65, 46)] autorelease];
        self.dayTwoLabel = [[[UILabel alloc] initWithFrame:CGRectMake(150.0, 21.0, 55, 15)] autorelease];
        self.dayThreeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(150.0, 37.0, 55, 15)] autorelease];
        
        self.dayOneLabel.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1];
        self.dayTwoLabel.textColor = [UIColor colorWithRed:0.53 green:0.53 blue:0.53 alpha:1];
        self.dayThreeLabel.textColor = [UIColor colorWithRed:0.53 green:0.53 blue:0.53 alpha:1];
        
        self.dayOneLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:40.0f];
        self.dayTwoLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:13.0f];
        self.dayThreeLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:13.0f];
        
        [self addSubview:self.dayOneLabel];
        [self addSubview:self.dayTwoLabel];
        [self addSubview:self.dayThreeLabel];
        
        self.dayOneView = [[UIImageView alloc] initWithFrame:CGRectMake(13, 10, 46, 48)];
        self.dayTwoView = [[UIImageView alloc] initWithFrame:CGRectMake(128, 18, 17, 16)];
        self.dayThreeView = [[UIImageView alloc] initWithFrame:CGRectMake(128, 34, 17, 16)];

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
        
    }
    
    [weekday release];
    
    BOOL isMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
    
    if (isMetric) {
        [oneText appendString:@"°"];
        [twoText appendString:@"°"];
        [threeText appendString:@"°"];
    } else {
        [oneText appendString:@"F"];
        [twoText appendString:@"F"];
        [threeText appendString:@"F"];
    }
    
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
        case 500:
            return [UIImage imageNamed:@"today_smallrain"];
            break;

        case 501:
            return [UIImage imageNamed:@"today_smallrain"];
            break;

        case 502:
            return [UIImage imageNamed:@"today_rain"];
            break;

        case 503:
            return [UIImage imageNamed:@"today_rain"];
            break;
        
        case 800:
            return [UIImage imageNamed:@"today_sun"];
            break;

        case 801:
            return [UIImage imageNamed:@"today_cloud"];
            break;

        case 802:
            return [UIImage imageNamed:@"today_cloud"];
            break;

        case 803:
            return [UIImage imageNamed:@"today_cloud"];
            break;

        case 804:
            return [UIImage imageNamed:@"today_cloud"];
            break;

        default:
            return [UIImage imageNamed:@"today_sun"];
            break;
    }
    
    return [UIImage imageNamed:@"today_sun"];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
