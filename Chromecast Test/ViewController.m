//
//  ViewController.m
//  Chromecast Test
//
//  Created by Jochem Toolenaar on 28/11/14.
//  Copyright (c) 2014 Jochem Toolenaar. All rights reserved.
//

#import "ViewController.h"
#import "GoogleCastController.h"

@interface ViewController ()
@property GoogleCastController* castController;
@property (weak, nonatomic) IBOutlet UIButton *castButton;
- (IBAction)onCastButtonTapped:(id)sender;

- (IBAction)onPlayTapped:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _castController = [[GoogleCastController alloc]initWithAppId:@"B948BDAD"];// add your own appID here
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(devicesFound) name:(NSString*)GoogleCastDeviceHasComeOnlineNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceDisconnected) name:(NSString*)GoogleCastSelectedDeviceDisconnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceConnected) name:(NSString*)GoogleCastDeviceConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(connectedToApp) name:(NSString*)GoogleConnectedToAppNotification object:nil];
    
}
-(void)connectedToApp{
    //play a track
    
    GCKImage *bgImage  = [[GCKImage alloc] initWithURL:[[NSURL alloc] initWithString:@"https://i1.sndcdn.com/artworks-000097503590-cjca4c-t500x500.jpg"] width:500 height:500];
    
    GCKMediaMetadata *meta = [_castController createMediaMetadata:@"Alex Cruz" subtitle:@"Deep & Sexy Podcast #15 - November 2014" bgImage:bgImage];
    GCKMediaInformation *info = [_castController createMediaInformation:meta streamUri:@"https://api.soundcloud.com/tracks/177437558/stream?client_id=5be8a5639583c700d021ac61bd06437d"];
    [_castController castMp3:info];
}
-(void)deviceConnected{
    [_castButton setImage:[UIImage imageNamed:@"cast_on.png"] forState:UIControlStateNormal];
}
-(void)deviceDisconnected{
     [_castButton setHidden:true];
}
-(void)devicesFound{
    [_castButton setHidden:false];
}
-(void)viewDidAppear:(BOOL)animated{
    [_castController startScanningForApp];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //
}

- (IBAction)onCastButtonTapped:(id)sender {
    if([_castController.deviceManager isConnected]){
        NSLog(@"Disconnecting device:%@", _castController.selectedDevice.friendlyName);
        // New way of doing things: We're not going to stop the applicaton. We're just going
        // to leave it.
        [_castController.deviceManager leaveApplication];
        // If you want to force application to stop, uncomment below
        //[self.deviceManager stopApplicationWithSessionID:self.applicationMetadata.sessionID];
        [_castController.deviceManager disconnect];
        [_castButton setImage:[UIImage imageNamed:@"cast_off.png"] forState:UIControlStateNormal];
    }else{
    
        UIAlertController *actions = [_castController getSheetForDevices];
        [self presentViewController:actions animated:true completion:nil];
    }
   
}

- (IBAction)onPlayTapped:(id)sender {
    //Show alert if not connected
    if (!_castController.deviceManager || !_castController.deviceManager.isConnected) {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Not Connected", nil)
                                   message:NSLocalizedString(@"Please connect to Cast device", nil)
                                  delegate:nil
                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
}
@end
