//
//  AppLovinCustomEventInterstitialEvent.m
//
//
//  Created by Thomas So on 5/20/17.
//
//

#import "AppLovinCustomEventInterstitial.h"

#if __has_include(<AppLovinSDK/AppLovinSDK.h>)
    #import <AppLovinSDK/AppLovinSDK.h>
#else
    #import "ALAdService.h"
    #import "ALInterstitialAd.h"
#endif

// This class implementation with the old classname is left here for backwards compatibility purposes.
@implementation AppLovinCustomEventInter
@end

@interface AppLovinCustomEventInterstitial() <ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate>

@property (nonatomic, strong) ALInterstitialAd *interstitialAd;
@property (nonatomic, strong) ALAd *loadedAd;

@end

@implementation AppLovinCustomEventInterstitial
@synthesize delegate;

static const BOOL kALLoggingEnabled = YES;
static NSString *const kALAdMobMediationErrorDomain = @"com.applovin.sdk.mediation.admob.errorDomain";

#pragma mark - GADCustomEventInterstitial Protocol

- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter label:(NSString *)serverLabel request:(GADCustomEventRequest *)request
{
    [self log: @"Requesting AppLovin interstitial"];
    
    [[ALSdk shared] setPluginVersion: @"AdMob-2.3"];
    
    ALAdService *adService = [ALSdk shared].adService;
    [adService loadNextAd: [ALAdSize sizeInterstitial] andNotify: self];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController
{
    if ( self.loadedAd )
    {
        self.interstitialAd = [[ALInterstitialAd alloc] initWithSdk: [ALSdk shared]];
        self.interstitialAd.adDisplayDelegate = self;
        self.interstitialAd.adVideoPlaybackDelegate = self;
        [self.interstitialAd showOver: rootViewController.view.window andRender: self.loadedAd];
    }
    else
    {
        [self log: @"Failed to show an AppLovin interstitial before one was loaded"];
        
        NSError *error = [NSError errorWithDomain: kALAdMobMediationErrorDomain
                                             code: kALErrorCodeUnableToRenderAd
                                         userInfo: @{NSLocalizedFailureReasonErrorKey : @"Adaptor requested to display an interstitial before one was loaded"}];
        
        [self.delegate customEventInterstitial: self didFailAd: error];
    }
}

#pragma mark - Ad Load Delegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    [self log: @"Interstitial did load ad: %@", ad.adIdNumber];
    
    self.loadedAd = ad;
    
    if ( [self.delegate respondsToSelector: @selector(customEventInterstitialDidReceiveAd:)] )
    {
        [self.delegate performSelector: @selector(customEventInterstitialDidReceiveAd:) withObject: self];
    }
    // Older versions of AdMob
    else
    {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [self.delegate customEventInterstitial: self didReceiveAd: ad];
#pragma GCC diagnostic pop
    }
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
{
    [self log: @"Interstitial failed to load with error: %d", code];
    
    NSError *error = [NSError errorWithDomain: kALAdMobMediationErrorDomain
                                         code: [self toAdMobErrorCode: code]
                                     userInfo: nil];
    [self.delegate customEventInterstitial: self didFailAd: error];
}

#pragma mark - Ad Display Delegate

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view
{
    [self log: @"Interstitial displayed"];
    
    [self.delegate customEventInterstitialWillPresent: self];
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view
{
    [self log: @"Interstitial dismissed"];
    
    [self.delegate customEventInterstitialWillDismiss: self];
    [self.delegate customEventInterstitialDidDismiss: self];
    
    self.interstitialAd = nil;
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view
{
    [self log: @"Interstitial clicked"];
    
    [self.delegate customEventInterstitialWillLeaveApplication: self];
}

#pragma mark - Video Playback Delegate

- (void)videoPlaybackBeganInAd:(ALAd *)ad
{
    [self log: @"Interstitial video playback began"];
}

- (void)videoPlaybackEndedInAd:(ALAd *)ad atPlaybackPercent:(NSNumber *)percentPlayed fullyWatched:(BOOL)wasFullyWatched
{
    [self log: @"Interstitial video playback ended at playback percent: %lu", percentPlayed.unsignedIntegerValue];
}

#pragma mark - Utility Methods

- (void)log:(NSString *)format, ...
{
    if ( kALLoggingEnabled )
    {
        va_list valist;
        va_start(valist, format);
        NSString *message = [[NSString alloc] initWithFormat: format arguments: valist];
        va_end(valist);
        
        NSLog(@"AppLovinCustomEventInterstitial: %@", message);
    }
}

- (GADErrorCode)toAdMobErrorCode:(int)appLovinErrorCode
{
    if ( appLovinErrorCode == kALErrorCodeNoFill )
    {
        return kGADErrorMediationNoFill;
    }
    else if ( appLovinErrorCode == kALErrorCodeAdRequestNetworkTimeout )
    {
        return kGADErrorTimeout;
    }
    else if ( appLovinErrorCode == kALErrorCodeInvalidResponse )
    {
        return kGADErrorReceivedInvalidResponse;
    }
    else if ( appLovinErrorCode == kALErrorCodeUnableToRenderAd )
    {
        return kGADErrorServerError;
    }
    else
    {
        return kGADErrorInternalError;
    }
}

@end
