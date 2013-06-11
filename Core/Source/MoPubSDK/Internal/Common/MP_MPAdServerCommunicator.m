//
//  MPAdServerCommunicator.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MP_MPAdServerCommunicator.h"

#import "MP_MPAdConfiguration.h"
#import "MPLogging.h"

const NSTimeInterval k_kRequestTimeoutInterval = 10.0;
NSString * const k_kHTTPHeaderFieldUserAgent = @"User-Agent";

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MP_MPAdServerCommunicator ()

- (NSError *)errorForStatusCode:(NSInteger)statusCode;
- (NSURLRequest *)adRequestForURL:(NSURL *)URL;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MP_MPAdServerCommunicator

@synthesize delegate = _delegate;
@synthesize URL = _URL;
@synthesize connection = _connection;
@synthesize responseData = _responseData;
@synthesize responseHeaders = _responseHeaders;

- (id)initWithDelegate:(id<MPAdServerCommunicatorDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [_connection cancel];
}

#pragma mark - Public

- (void)loadURL:(NSURL *)URL
{
    [self cancel];
    self.URL = URL;
    self.connection = [NSURLConnection connectionWithRequest:[self adRequestForURL:URL]
                                                    delegate:self];
}

- (void)cancel
{
    [self.connection cancel];
    self.connection = nil;
    self.responseData = nil;
    self.responseHeaders = nil;
}

#pragma mark - NSURLConnection delegate (NSURLConnectionDataDelegate in iOS 5.0+)

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response respondsToSelector:@selector(statusCode)]) {
        int statusCode = [(NSHTTPURLResponse *)response statusCode];
        if (statusCode >= 400) {
            [connection cancel];
            [self.delegate communicatorDidFailWithError:[self errorForStatusCode:statusCode]];
            return;
        }
    }

    self.responseData = [NSMutableData data];
    self.responseHeaders = [(NSHTTPURLResponse *)response allHeaderFields];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.delegate communicatorDidFailWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    MP_MPAdConfiguration *configuration = [[MP_MPAdConfiguration alloc]
                                         initWithHeaders:self.responseHeaders
                                         data:self.responseData];
    [self.delegate communicatorDidReceiveAdConfiguration:configuration];
}

#pragma mark - Internal

- (NSError *)errorForStatusCode:(NSInteger)statusCode
{
    NSString *errorMessage = [NSString stringWithFormat:
                              NSLocalizedString(@"MoPub returned status code %d.",
                                                @"Status code error"),
                              statusCode];
    NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:errorMessage
                                                          forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"mopub.com" code:statusCode userInfo:errorInfo];
}

- (NSURLRequest *)adRequestForURL:(NSURL *)URL
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL
        cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:k_kRequestTimeoutInterval];
    [request setValue:MP_MPUserAgentString() forHTTPHeaderField:k_kHTTPHeaderFieldUserAgent];
    return request;
}

@end
