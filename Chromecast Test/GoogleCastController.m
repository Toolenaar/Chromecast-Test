//
//  GoogleCastController.m
//  Chromecast Test
//
//  Created by Jochem Toolenaar on 28/11/14.
//  Copyright (c) 2014 Jochem Toolenaar. All rights reserved.
//

#import "GoogleCastController.h"

@interface GoogleCastController ()
@property GCKMediaControlChannel *mediaControlChannel;
@property GCKApplicationMetadata *applicationMetadata;


@property (nonatomic,strong)NSString *appId;
@property (nonatomic, strong) GCKDeviceScanner *deviceScanner;

@property (nonatomic, readonly) GCKMediaInformation *mediaInformation;


@end


@implementation GoogleCastController


-(id)initWithAppId:(NSString *)appId{
    self = [self init];
    if(self){
        _appId = appId;
    }
    return self;
}

-(void)startScanningForApp{

    _deviceScanner = [[GCKDeviceScanner alloc] init];
    
    GCKFilterCriteria *filterCriteria = [[GCKFilterCriteria alloc] init];
    filterCriteria = [GCKFilterCriteria criteriaForAvailableApplicationWithID:_appId];
    
    _deviceScanner.filterCriteria = filterCriteria;
    
    [_deviceScanner addListener:self];
    [_deviceScanner startScan];
}

-(void)connectToDevice:(GCKDevice *)device{
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    _deviceManager = [[GCKDeviceManager alloc] initWithDevice:device
                                           clientPackageName:[info objectForKey:@"CFBundleIdentifier"]];
    
    _deviceManager.delegate = self;
    [_deviceManager connect];
}


- (void)deviceDidComeOnline:(GCKDevice *)device {
    NSLog(@"device found!!!");
    //devices found let it be known
    [self sendNotification:(NSString *)GoogleCastDeviceHasComeOnlineNotification];
}



- (void)deviceDidGoOffline:(GCKDevice *)device {
    NSLog(@"device disappeared!!!");
    if(device == _selectedDevice){
        //let others know that the selected device has been disconnected
        [self sendNotification:(NSString *)GoogleCastSelectedDeviceDisconnectedNotification];
    }
}

-(UIAlertController *)getSheetForDevices{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Choose a device"
                                                                   message:@"Choose a device for music playback"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    for ( GCKDevice* device in _deviceScanner.devices ){
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:device.friendlyName style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  self.selectedDevice = [self getDeviceByName:action.title];
                                                                  [self connectToDevice:self.selectedDevice];
                                                              }];
        [alert addAction:defaultAction];
        
        
        
    }

    
    return alert;
}
-(GCKDevice *)getDeviceByName:(NSString *)name{
    
    for ( GCKDevice* device in _deviceScanner.devices ){
        if([name isEqualToString:device.friendlyName]){
             return device;
         }
     }
    return nil;
}

#pragma mark - GCKDeviceManagerDelegate
- (void)deviceManagerDidConnect:(GCKDeviceManager *)deviceManager {
    NSLog(@"connected!!");
    [self sendNotification:(NSString *)GoogleCastDeviceConnectedNotification];
    [self launchApplication:deviceManager];
    
}
-(void)launchApplication:(GCKDeviceManager *)deviceManager{
    [deviceManager launchApplication:_appId];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata
            sessionID:(NSString *)sessionID
  launchedApplication:(BOOL)launchedApp {
    
    _mediaControlChannel = [[GCKMediaControlChannel alloc] init];
    _mediaControlChannel.delegate = self;
    [deviceManager addChannel:_mediaControlChannel];
    [self sendNotification:(NSString *)GoogleConnectedToAppNotification];
}
- (void)deviceManager:(GCKDeviceManager *)deviceManager didDisconnectWithError:(GCKError *)error {
    NSLog(@"Received notification that device disconnected");
    
    if (error != nil) {
        [self showError:error];
    }
    

    
}
#pragma mark - Casting
-(void)castMp3:(GCKMediaInformation *)mediaInformation{
    //cast video
    [_mediaControlChannel loadMedia:mediaInformation autoplay:TRUE playPosition:0];
}

-(GCKMediaInformation *)createMediaInformation:(GCKMediaMetadata *)meta streamUri:(NSString *)streamUri{
    //define Media information
    GCKMediaInformation *mediaInformation =
    [[GCKMediaInformation alloc] initWithContentID:streamUri
                                        streamType:GCKMediaStreamTypeUnknown
                                       contentType:@"audio/mp3"
                                          metadata:meta
                                    streamDuration:0
                                        customData:nil];
    return mediaInformation;
    
}

-(GCKMediaMetadata *)createMediaMetadata:(NSString *)title subtitle:(NSString *)subtitle bgImage:(GCKImage *)bgImage{
    GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] init];
    
    [metadata setString:title forKey:kGCKMetadataKeyTitle];
    
    [metadata setString:subtitle
                 forKey:kGCKMetadataKeySubtitle];
    
    [metadata addImage:bgImage];
    
    return metadata;
}

#pragma mark - Notify
-(void)sendNotification:(NSString *)notificaiton{
    NSNotification *notificationObject = [NSNotification notificationWithName:notificaiton object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter]postNotification:notificationObject];
    
}
- (void)showError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                    message:NSLocalizedString(error.description, nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

@end
