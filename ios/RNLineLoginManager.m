
#import "RNLineLoginManager.h"
#import <LineSDK/LineSDK.h>

@interface RNLineLoginManager ()<LineSDKLoginDelegate>
@property (strong, nonatomic) RCTPromiseResolveBlock loginResolver;
@property (strong, nonatomic) RCTPromiseRejectBlock loginRejecter;
@property (strong, nonatomic) LineSDKAPI *apiClient;
@end

@implementation RNLineLoginManager

#pragma mark - Object life cyle

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}


RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(login:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    self.loginResolver = resolve;
    self.loginRejecter = reject;
    [[LineSDKLogin sharedInstance] startLoginWithPermissions:@[@"profile"/*, @"friends", @"groups"*/]];
}

RCT_EXPORT_METHOD(getUserProfile:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.apiClient getProfileWithCompletion:^(LineSDKProfile * _Nullable profile, NSError * _Nullable error) {
        if (error) {
            reject(@"LineSDK", @"Get Line Profile Failed", error);
        } else {
            NSString * userID = profile.userID;
            NSString * displayName = profile.displayName;
            NSString * statusMessage = profile.statusMessage;
            NSURL * pictureURL = profile.pictureURL;
            
            NSString * pictureUrlString = @"";
            // If the user does not have a profile picture set, pictureURL will be nil
            if (pictureURL) {
                pictureUrlString = profile.pictureURL.absoluteString;
            }
            
            if (!userID) {
                userID = @"";
            }
            if (!displayName) {
                displayName = @"";
            }
            if (!statusMessage) {
                statusMessage = @"";
            }
            
            NSDictionary *userTokenInfo = @{
                                            @"user_id" : userID,
                                            @"display_name" : displayName,
                                            @"picture_url" : pictureUrlString,
                                            @"status_message" : statusMessage
                                            };
            resolve(userTokenInfo);
        }
    }];
}

RCT_EXPORT_METHOD(logout)
{
    [self.apiClient logoutWithCompletion:^(BOOL success, NSError * _Nullable error) {
        
    }];
}

//initialize LINE sdk
- (id) init {
    self = [super init];
    if (self) {
        // Set the LINE Login Delegate
        [LineSDKLogin sharedInstance].delegate = self;
        _apiClient = [[LineSDKAPI alloc] initWithConfiguration:[LineSDKConfiguration defaultConfig]];
    }
    return self;
}

#pragma mark LineSDKLoginDelegate

- (void)didLogin:(LineSDKLogin *)login
      credential:(LineSDKCredential *)credential
         profile:(LineSDKProfile *)profile
           error:(NSError *)error
{
    if (error) {
        self.loginRejecter(@"LineSDK", @"Login Line Failed", error);
    } else {
        // Login success. Extracts the access token, user profile ID, display name, status message, and profile picture.
        NSString * accessToken = credential.accessToken.accessToken;
        NSString * userID = profile.userID;
        NSString * displayName = profile.displayName;
        NSString * statusMessage = profile.statusMessage;
        NSURL * pictureURL = profile.pictureURL;

        NSString * pictureUrlString = @"";
        // If the user does not have a profile picture set, pictureURL will be nil
        if (pictureURL) {
            pictureUrlString = profile.pictureURL.absoluteString;
        }
        
        if (!userID) {
            userID = @"";
        }
        if (!displayName) {
            displayName = @"";
        }
        if (!statusMessage) {
            statusMessage = @"";
        }

        NSDictionary *userTokenInfo = @{
                                        @"access_token" : accessToken,
                                        @"user_id" : userID,
                                        @"display_name" : displayName,
                                        @"picture_url" : pictureUrlString,
                                        @"status_message" : statusMessage
                                        };
        self.loginResolver(userTokenInfo);
    }
}
@end
  
