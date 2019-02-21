
#import "RNLineLoginManager.h"
//#import <LineAdapter/LineAdapter.h>
//#import <LineAdapterUI/LineAdapterUI.h>
#import <LineSDK/LineSDK.h>

@interface RNLineLoginManager ()<LineSDKLoginDelegate>
@property (strong, nonatomic) RCTPromiseResolveBlock loginResolver;
@property (strong, nonatomic) RCTPromiseRejectBlock loginRejecter;
@property (strong, nonatomic) LineSDKAPI *apiClient;
//@property (strong, nonatomic) UIViewController *navigationController;
@end

@implementation RNLineLoginManager

#pragma mark - Object life cyle

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}


RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(login:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    self.loginResolver = resolve;
    self.loginRejecter = reject;
//
//    [self login];
    
//    NSLog(@"Button pressed:");
    [[LineSDKLogin sharedInstance] startLoginWithPermissions:@[@"profile"/*, @"friends", @"groups"*/]];
}

RCT_EXPORT_METHOD(getUserProfile:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
//    [self getUserProfileInfo:resolve rejecter:reject];
    
    [self.apiClient getProfileWithCompletion:^(LineSDKProfile * _Nullable profile, NSError * _Nullable error) {
        NSString * userID = profile.userID;
        NSString * displayName = profile.displayName;
        NSString * statusMessage = profile.statusMessage;
        NSURL * pictureURL = profile.pictureURL;
        
        NSString * pictureUrlString;
        
        // If the user does not have a profile picture set, pictureURL will be nil
        if (pictureURL) {
            pictureUrlString = profile.pictureURL.absoluteString;
        }
    }];
    
//        [[self.adapter getLineApiClient] getMyProfileWithResultBlock:^(NSDictionary *aResult, NSError *aError)
//         {
//             if (aResult)
//             {
//                 // API call was successfully.
//                 resolve(aResult);
//
//             }
//             else
//             {
//                 // API call failed.
//                 reject(@"LineSDK", @"Failed to get user profile", aError);
//             }
//         }];
}

RCT_EXPORT_METHOD(logout)
{
//    [self.adapter unauthorize];
    [self.apiClient logoutWithCompletion:^(BOOL success, NSError * _Nullable error) {
        
    }];
}

//initialize LINE sdk
- (id) init {
    self = [super init];
    if (self)
    {
//        _adapter = [[LineAdapter alloc] initWithConfigFile];
//
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(lineAdapterAuthorizationDidChange:)
//                                                     name:LineAdapterAuthorizationDidChangeNotification object:nil];
    
        
        // Set the LINE Login Delegate
        [LineSDKLogin sharedInstance].delegate = self;
        
        _apiClient = [[LineSDKAPI alloc] initWithConfiguration:[LineSDKConfiguration defaultConfig]];
        
       
        
    }
    return self;
}
//
//- (void) cancel:(id)sender {
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    if (self.loginRejecter) {
//        self.loginRejecter(@"LineSDK", @"Login Line Canceled", nil);
//    }
//}

#pragma mark - Login
//
//- (void)login
//{
//    if ([self.adapter isAuthorized]) {
//        self.loginResolver([self getUserTokenInfo]);
//    } else {
//        [self handleAuthorization];
//    }
//}
//
//- (void)handleAuthorization
//{
//    if ([self.adapter canAuthorizeUsingLineApp])
//    {
//        // Authenticate with LINE application
//        [self.adapter authorize];
//    }
//    else
//    {
//        // Authenticate with WebView
//        UIViewController *viewController;
//        viewController = [[LineAdapterWebViewController alloc] initWithAdapter:self.adapter
//                                                        withWebViewOrientation:kOrientationAll];
//        [[viewController navigationItem] setLeftBarButtonItem:[LineAdapterNavigationController
//                                                               barButtonItemWithTitle:@"Cancel" target:self action:@selector(cancel:)]];
//        
//        self.navigationController = [[LineAdapterNavigationController alloc]
//                                     initWithRootViewController:viewController];
//        
//        // get current view controller
//        id rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
//        if ([rootViewController isKindOfClass:[UIViewController class]]) {
//            rootViewController = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
//            [rootViewController presentViewController:self.navigationController animated:YES completion:nil];
//        } else {
//            NSLog(@"rootViewController is not a navigation controller instance");
//        }
//    }
//
//}
//
//- (NSDictionary *) getUserTokenInfo {
//    LineApiClient *apiClient = [self.adapter getLineApiClient];
//    NSDictionary *userTokenInfo = @{
//                                    @"mid" : self.adapter.MID,
//                                    @"accessToken" : apiClient.accessToken,
//                                    @"refreshToken" : apiClient.refreshToken,
//                                    @"expire" : [NSString stringWithFormat:@"%@", apiClient.expiresDate]
//                                   };
//    return userTokenInfo;
//}
//
//- (void)lineAdapterAuthorizationDidChange:(NSNotification*)aNotification
//{
//    LineAdapter *_adapter = [aNotification object];
//    if ([_adapter isAuthorized])
//    {
//        NSLog(@"Login success");
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//        if (self.loginResolver) {
//            self.loginResolver([self getUserTokenInfo]);
//        }
//    }
//    else
//    {
//        NSError *error = [[aNotification userInfo] objectForKey:@"error"];
//        if (error)
//        {
//            NSLog(@"Login failed");
//            
//            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//            if (self.loginRejecter) {
//                self.loginRejecter(@"LineSDK", @"Login Line Failed", error);
//            }
//            
//            NSString *errorMessage = [error localizedDescription];
//            NSInteger code = [error code];
//            if (code == kLineAdapterErrorMissingConfiguration)
//            {
//                // URL Types is not set correctly
//            }
//            else if (code == kLineAdapterErrorAuthorizationAgentNotAvailable)
//            {
//                // The LINE application is not installed
//            }
//            else if (code == kLineAdapterErrorInvalidServerResponse)
//            {
//                // The response from the server is incorrect
//            }
//            else if (code == kLineAdapterErrorAuthorizationDenied)
//            {
//                // The user has cancelled the authentication and authorization
//            }
//            else if (code == kLineAdapterErrorAuthorizationFailed)
//            {
//                // The authentication and authorization has failed for an unknown reason
//            }
//        }
//    }
//}
//
//- (void) getUserProfileInfo:(RCTPromiseResolveBlock)resolve
//                          rejecter:(RCTPromiseRejectBlock)reject
//{
//    [[self.adapter getLineApiClient] getMyProfileWithResultBlock:^(NSDictionary *aResult, NSError *aError)
//     {
//         if (aResult)
//         {
//             // API call was successfully.
//             resolve(aResult);
//             
//         }
//         else
//         {
//             // API call failed.
//             reject(@"LineSDK", @"Failed to get user profile", aError);
//         }
//     }];
//}

#pragma mark LineSDKLoginDelegate

- (void)didLogin:(LineSDKLogin *)login
      credential:(LineSDKCredential *)credential
         profile:(LineSDKProfile *)profile
           error:(NSError *)error
{
    if (error) {
        // Login failed with an error. Use the error parameter to identify the problem.
        NSLog(@"Error: %@", error.localizedDescription);
    }
    else {
        
        // Login success. Extracts the access token, user profile ID, display name, status message, and profile picture.
        NSString * accessToken = credential.accessToken.accessToken;
        NSString * userID = profile.userID;
        NSString * displayName = profile.displayName;
        NSString * statusMessage = profile.statusMessage;
        NSURL * pictureURL = profile.pictureURL;
        
        NSString * pictureUrlString;
        
        // If the user does not have a profile picture set, pictureURL will be nil
        if (pictureURL) {
            pictureUrlString = profile.pictureURL.absoluteString;
        }
        
    }
}
@end
  
