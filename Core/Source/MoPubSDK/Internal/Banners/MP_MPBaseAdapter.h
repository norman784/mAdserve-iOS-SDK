//
//  MPBaseAdapter.h
//  MoPub
//
//  Created by Nafis Jamal on 1/19/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MP_MPAdView.h"

@protocol MPAdapterDelegate;
@class MP_MPAdConfiguration;

@interface MP_MPBaseAdapter : NSObject 
{
	id<MPAdapterDelegate> __weak _delegate;
    NSURL *_impressionTrackingURL;
    NSURL *_clickTrackingURL;
}

@property (weak, nonatomic, readonly) id<MPAdapterDelegate> delegate;
@property (nonatomic, copy) NSURL *impressionTrackingURL;
@property (nonatomic, copy) NSURL *clickTrackingURL;

- (id)initWithAdapterDelegate:(id<MPAdapterDelegate>)delegate;

/*
 * Sets the adapter's delegate to nil.
 */
- (void)unregisterDelegate;

/*
 * -getAdWithParams: needs to be implemented by adapter subclasses that want to load native ads.
 * -getAd simply calls -getAdWithParams: with a nil dictionary.
 */
- (void)getAd;
- (void)getAdWithParams:(NSDictionary *)params;

/*
 * This method wraps -getAdWithParams: with calls to -retain and -release, since that method
 * may prematurely deallocate the adapter during its own execution (as the result of various
 * callbacks).
 */
- (void)_getAdWithParams:(NSDictionary *)params;

- (void)getAdWithConfiguration:(MP_MPAdConfiguration *)configuration;
- (void)_getAdWithConfiguration:(MP_MPAdConfiguration *)configuration;

/*
 * Your subclass should implement this method if your native ads vary depending on orientation.
 */
- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation;

- (void)trackImpression;

- (void)trackClick;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MPAdapterDelegate

@required

- (MP_MPAdView *)adView;
- (id<MPAdViewDelegate>)adViewDelegate;
- (CGSize)maximumAdSize;
- (UIViewController *)viewControllerForPresentingModalView;
- (MPNativeAdOrientation)allowedNativeAdsOrientation;

- (void)pauseAutorefresh;
- (void)resumeAutorefreshIfEnabled;

/*
 * These callbacks notify you that the adapter (un)successfully loaded an ad.
 */
- (void)adapter:(MP_MPBaseAdapter *)adapter didFailToLoadAdWithError:(NSError *)error;
- (void)adapter:(MP_MPBaseAdapter *)adapter didFinishLoadingAd:(UIView *)ad 
		shouldTrackImpression:(BOOL)shouldTrack;

/*
 * These callbacks notify you that the user interacted (or stopped interacting) with the native ad.
 */
- (void)userActionWillBeginForAdapter:(MP_MPBaseAdapter *)adapter;
- (void)userActionDidFinishForAdapter:(MP_MPBaseAdapter *)adapter;

/*
 * This callback notifies you that user has tapped on an ad which will cause them to leave the 
 * current application (e.g. the ad action opens the iTunes store, Mobile Safari, etc).
 */
- (void)userWillLeaveApplicationFromAdapter:(MP_MPBaseAdapter *)adapter;

@end
