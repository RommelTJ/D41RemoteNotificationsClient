//
//  AppDelegate.m
//  D41RemoteNotificationsClient
//
//  Created by Rommel Rico on 2/12/15.
//  Copyright (c) 2015 Rommel Rico. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Ask user's permission to send notifications
    UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [application registerUserNotificationSettings:settings];
    
    return YES;
}

-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    //Determine if the user has allowed notifications
    if (notificationSettings.types) {
        //Now register for remote notifications.
        [application registerForRemoteNotifications];
    }
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"deviceToken: %@", deviceToken);
    
    //Option 1: Try JSON.
    //Put token into dictionary, then convert dictionary into JSON.
    NSDictionary *d = @{@"deviceToken": deviceToken,
                        @"username": @"johndoe" };
    //Can this be converted to JSON?
    if ([NSJSONSerialization isValidJSONObject:d]) {
        //This can be converted to JSON
        NSError *myError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:d options:0 error:&myError];
        if (myError) {
            NSLog(@"NSJSONSerialization error: %@", myError);
            return;
        }
        //TODO: Send JSON data.
    } else {
        NSLog(@"Cannot be converted to JSON using NSJSONSerialization");
    }
    
    //Option 2: Try NSPropertyListSerialization.
    NSError *myError = nil;
    NSData *xmlData = [NSPropertyListSerialization dataWithPropertyList:d format:NSPropertyListXMLFormat_v1_0 options:0 error:&myError];
    
    //NOTE: We do not yet know the address and port of the server.
    //BUT: Suppose we have a harcoded servert/port.
    NSString *urlString = @"http://demo.com/deviceToken";
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = xmlData;
    
    
    //Option 3: Just use the raw binary data.
    request.HTTPBody = deviceToken;
    //TODO: You may want to cash info about how often to do this.
    //      You could keep a flag that says go to server.
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        //Check for errors.
        NSLog(@"connectionError: %@", connectionError);
        NSLog(@"response: %@", response);
        if (response) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSLog(@"statusCode: %li", httpResponse.statusCode);
        }
    }];
    
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"Error: %@", error);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
