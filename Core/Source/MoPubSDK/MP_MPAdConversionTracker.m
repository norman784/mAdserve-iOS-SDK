//
//  MPAdConversionTracker.m
//  MoPub
//
//  Created by Andrew He on 2/4/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MP_MPAdConversionTracker.h"
#import "MPConstants.h"
#import "MPGlobal.h"
#import "MPLogging.h"

#define kUserAgentContextKey @"user-agent"
#define kApplicationIdContextKey @"app-id"

@interface MP_MPAdConversionTracker (Internal)
- (void)reportApplicationOpenSynchronous:(NSDictionary *)context;
@end

@implementation MP_MPAdConversionTracker

+ (MP_MPAdConversionTracker *)sharedConversionTracker
{
	static MP_MPAdConversionTracker *sharedConversionTracker;
	@synchronized(self)
	{
		if (!sharedConversionTracker)
			sharedConversionTracker = [[MP_MPAdConversionTracker alloc] init];
		return sharedConversionTracker;
	}
}

- (void)reportApplicationOpenForApplicationID:(NSString *)appID
{
	// MPUserAgentString() must be called on the main thread, since it manipulates a UIWebView.
	NSString *userAgent = MP_MPUserAgentString();
	NSDictionary *context = [NSDictionary dictionaryWithObjectsAndKeys:
							 userAgent, kUserAgentContextKey,
							 appID, kApplicationIdContextKey, nil];
	[self performSelectorInBackground:@selector(reportApplicationOpenSynchronous:) 
						   withObject:context];
}

#pragma mark -
#pragma mark Internal

- (void)reportApplicationOpenSynchronous:(NSDictionary *)context
{
	@autoreleasepool {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		if ([paths count] <= 0) { return;}

		NSString *documentsDir = [paths objectAtIndex:0];
		NSString *appOpenLogPath = [documentsDir stringByAppendingPathComponent:@"mopubAppOpen.log"];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		// The existence of mopubAppOpen.log tells us whether we have already reported this app open.
		if ([fileManager fileExistsAtPath:appOpenLogPath]) { return;}
		NSString *appID = [context objectForKey:kApplicationIdContextKey];
		NSString *userAgent = [context objectForKey:kUserAgentContextKey];
		NSString *appOpenUrlString = [NSString stringWithFormat:@"http://%@/m/open?v=8&udid=%@&id=%@",
									  HOSTNAME,
									  MP_MPAdvertisingIdentifier(),
									  appID];
		MPLogInfo(@"Reporting application did launch for the first time to MoPub: %@", appOpenUrlString);
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
										[NSURL URLWithString:appOpenUrlString]];
		[request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
		NSURLResponse *response;
		NSError *error = nil;
		NSData *responseData = [NSURLConnection sendSynchronousRequest:request 
													 returningResponse:&response 
																 error:&error];
		if ((!error) && ([(NSHTTPURLResponse *)response statusCode] == 200) && 
			([responseData length] > 0))
		{
			[fileManager createFileAtPath:appOpenLogPath contents:nil attributes:nil];
		}
	}
}
@end
