//
//  MPBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MP_MPBannerCustomEvent.h"

@implementation MP_MPBannerCustomEvent

//@synthesize delegate;

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    // The default implementation of this method does nothing. Subclasses must override this method
    // and implement code to load a banner here.
}

- (void)dealloc
{
    // Your subclass should implement -dealloc if it needs to perform any cleanup.
    self.delegate = nil;
}

@end
