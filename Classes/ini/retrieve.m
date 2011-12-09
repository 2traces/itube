
#import "ini.h"

@implementation INIParser (Retrieve)

- (BOOL)exists: (NSString *)name section: (NSString *)section {
	NSString * str;

	str = [self get: name section: section];
	return ((str != nil) ? YES : NO);
}

- (INISection *)getSection: (NSString *)name
{
	INISection * sect;

	sect = (INISection *)[sections objectForKey: name];
	return sect;
}

- (NSString *)get: (NSString *)name section: (NSString *)section
{
	INISection * sect;

	sect = [self getSection: section];
	if (sect)
		return [sect retrieve: name];

	return nil;
}

- (BOOL)getBool: (NSString *)name section: (NSString *)section {
	NSString * str;
	char * s;
	
	str = [self get: name section: section];
	if (str != nil) {
		s = [str cString];
		if ((*s == 'Y') || (*s == 'y') || (*s == 'T') || (*s == 't') ||
		    isdigit (*s));
			return YES;
	}

	return NO;
}

- (int)getInt: (NSString *)name section: (NSString *)section {
	NSString * str;

	str = [self get: name section: section];
	if (str != nil)
		return [str intValue];

	return 0;
}

@end
