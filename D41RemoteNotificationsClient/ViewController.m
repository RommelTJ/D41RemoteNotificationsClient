//
//  ViewController.m
//  D41RemoteNotificationsClient
//
//  Created by Rommel Rico on 2/12/15.
//  Copyright (c) 2015 Rommel Rico. All rights reserved.
//

#import "ViewController.h"

#define DEVICE_SERVICE_TYPE @"_http._tcp"
#define DEVICE_SERVICE_NAME @"com.rommelrico.DeviceToken"

@interface ViewController () <NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property (weak, nonatomic) IBOutlet UILabel *myServerAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *myServerPortLabel;
@property (weak, nonatomic) IBOutlet UITextView *myTextView;
@property NSNetService *theDeviceTokenService;
@property NSNetServiceBrowser *myServiceBrowser;
@property struct sockaddr_in *socketAddress;
@property NSMutableString *ms;

@end

@implementation ViewController

- (IBAction)doBrowserForServer:(id)sender {
    UIButton *button = sender;
    static BOOL browsingFlag = YES;
    if (browsingFlag) {
        //Start Browsing
        self.myServiceBrowser = [[NSNetServiceBrowser alloc]init];
        self.myServiceBrowser.delegate = self;
        [self.myServiceBrowser searchForServicesOfType:DEVICE_SERVICE_TYPE inDomain:@""];
        //Set button to stop browsing.
        [button setTitle:@"Stop Browsing" forState:UIControlStateNormal];
    } else {
        [self.myServiceBrowser stop];
        [button setTitle:@"Start Browsing" forState:UIControlStateNormal];
    }
    browsingFlag = !browsingFlag;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.ms = [NSMutableString new];
    self.myTextView.text = @"";
    self.myTextView.editable = NO;
}

- (void)updateDisplay:(const char*)msg {
    [self.ms appendFormat:@"%s\n", msg];
    self.myTextView.text = self.ms;
}

-(void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
    [self updateDisplay:__func__];
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
    [self updateDisplay:__FUNCTION__];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [self updateDisplay:__FUNCTION__];
    [self updateDisplay:[aNetService.name UTF8String]];
    //Look for a specific Device Service
    if ([aNetService.name isEqualToString:DEVICE_SERVICE_NAME]) {
        //Found our specific service
        self.theDeviceTokenService = aNetService;
        self.theDeviceTokenService.delegate = self;
        [self updateDisplay:"Found our service!"];
        [self updateDisplay:"Resolving server address..."];
        [self.theDeviceTokenService resolveWithTimeout:30]; //30 seconds.
    }
}

-(void)netServiceDidResolveAddress:(NSNetService *)sender{
    [self updateDisplay:__func__];
}

-(void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    [self updateDisplay:__func__];
    [self updateDisplay:[[errorDict description] UTF8String]];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [self updateDisplay:__func__];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
