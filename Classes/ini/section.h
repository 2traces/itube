#import <Foundation/Foundation.h>

@interface INISection : NSObject {

	NSMutableDictionary * assignments;
	NSString * sname;
}

@property (nonatomic, retain)	NSMutableDictionary * assignments;
- initWithName: (NSString *)name;
- (void)dealloc;
- (void)insert: (NSString *)name value: (NSString *)value;
- (NSString *)retrieve: (NSString *)name;

@end
