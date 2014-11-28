//
//  GoogleCastController.h
//  Chromecast Test
//
//  Created by Jochem Toolenaar on 28/11/14.
//  Copyright (c) 2014 Jochem Toolenaar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleCast/GoogleCast.h>
@import UIKit;

static const NSString *GoogleCastDeviceHasComeOnlineNotification = @"GoogleCastDeviceHasComeOnlineNotification";
static const NSString *GoogleCastSelectedDeviceDisconnectedNotification = @"GoogleCastSelectedDeviceDisconnectedNotification";
static const NSString *GoogleCastDeviceConnectedNotification = @"GoogleCastDeviceConnectedNotification";
static const NSString *GoogleConnectedToAppNotification = @"GoogleConnectedToAppNotification";

@interface GoogleCastController : NSObject <GCKDeviceScannerListener,GCKDeviceManagerDelegate,GCKMediaControlChannelDelegate>
@property (nonatomic, strong) GCKDeviceManager *deviceManager;
@property (nonatomic,strong) GCKDevice *selectedDevice;
-(id)initWithAppId:(NSString *)appId;
-(void)startScanningForApp;
-(void)connectToDevice:(GCKDevice*)device;
-(UIAlertController *)getSheetForDevices;
-(void)castMp3:(GCKMediaInformation *)mediaInformation;
-(GCKMediaInformation *)createMediaInformation:(GCKMediaMetadata *)meta streamUri:(NSString *)streamUri;
-(GCKMediaMetadata *)createMediaMetadata:(NSString *)title subtitle:(NSString *)subtitle bgImage:(GCKImage *)bgImage;

@end
