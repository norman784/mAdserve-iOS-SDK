//
//  MPBaseAdapter.m
//  MoPub
//
//  Created by Nafis Jamal on 1/19/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MP_MPBaseAdapter.h"

#import "MP_MPAdConfiguration.h"
#import "MPLogging.h"

@interface MP_MPBaseAdapter ()
{
    NSMutableURLRequest *_metricsURLRequest;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MP_MPBaseAdapter

@synthesize delegate = _delegate;
@synthesize impressionTrackingURL = _impressionTrackingURL;
@synthesize clickTrackingURL = _clickTrackingURL;

- (id)initWithAdapterDelegate:(id<MPAdapterDelegate>)delegate
{
	if (self = [super init]) {
		_delegate = delegate;

        _metricsURLRequest = [[NSMutableURLRequest alloc] init];
        [_metricsURLRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [_metricsURLRequest setValue:MP_MPUserAgentString() forHTTPHeaderField:@"User-Agent"];
	}
	return self;
}

- (void)dealloc
{
	[self unregisterDelegate];
}

- (void)unregisterDelegate
{
	_delegate = nil;
}

#pragma mark - Requesting Ads

- (void)getAdWithConfiguration:(MP_MPAdConfiguration *)configuration
{
    // To be implemented by subclasses.
    [self doesNotRecognizeSelector:_cmd];
}

- (void)_getAdWithConfiguration:(MP_MPAdConfiguration *)configuration
{
    self.impressionTrackingURL = [configuration impressionTrackingURL];
    self.clickTrackingURL = [configuration clickTrackingURL];

    [self getAdWithConfiguration:configuration];
}

#pragma mark - Rotation

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
	// Do nothing by default. Subclasses can override.
	MPLogDebug(@"rotateToOrientation %d called for adapter %@ (%p)",
		  newOrientation, NSStringFromClass([self class]), self);
}

#pragma mark - Metrics

- (void)trackImpression
{
    MPLogDebug(@"Tracking banner impression: %@", self.impressionTrackingURL);
    [_metricsURLRequest setURL:self.impressionTrackingURL];
    [NSURLConnection connectionWithRequest:_metricsURLRequest delegate:nil];
}

- (void)trackClick
{
    MPLogDebug(@"Tracking banner click: %@", self.clickTrackingURL);
    [_metricsURLRequest setURL:self.clickTrackingURL];
    [NSURLConnection connectionWithRequest:_metricsURLRequest delegate:nil];
}

#pragma mark - Requesting Ads (Legacy)

- (void)getAd
{
	[self getAdWithParams:nil];
}

- (void)getAdWithParams:(NSDictionary *)params
{
	// To be implemented by subclasses.
	[self doesNotRecognizeSelector:_cmd];
}

- (void)_getAdWithParams:(NSDictionary *)params
{
    [self getAdWithParams:params];
}

@end
