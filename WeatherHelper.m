//
//  WeatherHelper.m
//  tube
//
//  Created by Сергей on 11.07.13.
//
//

#import "WeatherHelper.h"
#import "tubeAppDelegate.h"
#import "CityMap.h"
#import "Reachability.h"
#import "StatusDownloader.h"
#import "WeatherXMLParser.h"

@implementation WeatherHelper

@synthesize weatherURL;
@synthesize infoDictionary;
@synthesize lastUpdate;
@synthesize isRequesting;

static WeatherHelper * _sharedHelper;

+ (WeatherHelper *) sharedHelper {
    
    if (_sharedHelper != nil) {
        return _sharedHelper;
    }
    _sharedHelper = [[WeatherHelper alloc] init];
    
    return _sharedHelper;
}

-(id) init
{
	if ((self=[super init]))
	{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapChanged:) name:@"kMapChanged" object:nil];
        self.weatherURL = [self getCityWeatherURL];
        self.lastUpdate = nil;
        self.isRequesting = NO;
        
        if (self.weatherURL) {
            [self recieveWeatherInfo];
        }
	}
	
	return self;
}

-(NSString*)getCityWeatherURL
{
    NSMutableString *mainURL=nil;
    
    NSString *currentMap = [[(tubeAppDelegate*)[[UIApplication sharedApplication] delegate] cityMap] thisMapName];
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"maps.plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    NSArray *mapIDs = [dict allKeys];
    for (NSString* mapID in mapIDs) {
        NSDictionary *map = [dict objectForKey:mapID];
        if ([[map objectForKey:@"filename"] isEqual:currentMap]) {
            if ([map objectForKey:@"weather_info"]) {
                mainURL = [NSMutableString stringWithString:[map objectForKey:@"weather_info"]];

                BOOL isMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
                
                if (isMetric) {
                    [mainURL appendString:@"&units=metric"];
                } else {
                    [mainURL appendString:@"&units=imperial"];
                }
            }
        }
    }
    
    [dict release];
    
    return mainURL;
}

-(void)recieveWeatherInfo
{
    self.isRequesting = YES;
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if (netStatus != NotReachable) {
        StatusDownloader *statusDownloader = [[StatusDownloader alloc] init];
        statusDownloader.delegate = self;
        statusDownloader.imageURLString=self.weatherURL;
        [statusDownloader startDownload];
        [statusDownloader release];
    }
}

-(void)statusInfoDidLoad:(NSString*)xmlString server:(StatusDownloader*)server
{
    if (xmlString) {
        WeatherXMLParser *parseOperation = [[WeatherXMLParser alloc] initWithString:xmlString];
        tubeAppDelegate *appDelegate = (tubeAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [appDelegate.parseQueue addOperation:parseOperation];
        [parseOperation release];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(parseComplete:)
                                                     name:kParseComplete
                                                   object:nil];
    }
}

-(void)connectionFailed:(StatusDownloader*)server
{
    self.isRequesting = NO;
}

-(void)parseComplete:(NSNotification*)note
{
    NSMutableDictionary *dict = [note object];
    
    self.infoDictionary = dict;
    
    self.lastUpdate = [NSDate date];
    
    self.isRequesting = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kWeatherInfo" object:self.infoDictionary];
}

-(NSDictionary*)getWeatherInformation
{
    if (self.infoDictionary) {
        
        if ([self.lastUpdate timeIntervalSinceNow]<-86400 && !isRequesting) {

            self.infoDictionary = nil;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kWeatherInfo" object:self.infoDictionary];
        }
        
        if ([self.lastUpdate timeIntervalSinceNow]<-3600 && !isRequesting) {
            [self recieveWeatherInfo];
        }
        
        return self.infoDictionary;
        
    } 
    
    return nil;
}

- (void)mapChanged:(NSNotification*)note
{
    self.weatherURL = [self getCityWeatherURL];
    self.lastUpdate = nil;
    self.isRequesting = NO;
    self.infoDictionary = nil;
    
    if (self.weatherURL) {
        [self recieveWeatherInfo];
    }
}

-(void)dealloc
{
    [weatherURL release];
    [infoDictionary release];
    [lastUpdate release];

    [super dealloc];
}

@end
