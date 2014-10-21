/*
 * Copyright 2014 Nathan Bruer
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
//
//  CDVLineaDevice.h
//
//  Created by Nathan Bruer.
//
#ifndef LOG
	#define LOG(s, ...) NSLog(@"<%s : (%d)> %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#endif
#import <Cordova/CDVPlugin.h>
#import <Foundation/NSNull.h>
#import "DTDevices.h"
#import <ExternalAccessory/ExternalAccessory.h>
@interface CDVLineaDevice : CDVPlugin <DTDeviceDelegate>{
    DTDevices *linea;
    int lineaConnectionState;
}
@property (retain) NSString* callbackId;

- (void) connectLinea:(NSNotification *)notification;
- (void) disconnectLinea:(NSNotification *)notification;

// Start JS Callable Functions
- (void) playSound:(CDVInvokedUrlCommand*)command;
- (void) startScan:(CDVInvokedUrlCommand*)command;
- (void) stopScan:(CDVInvokedUrlCommand*)command;
- (void) setScanMode:(CDVInvokedUrlCommand*)command;
- (void) setScanBeep:(CDVInvokedUrlCommand*)command;
- (void) setScanButtonMode:(CDVInvokedUrlCommand*)command;
- (void) setMSCardDataMode:(CDVInvokedUrlCommand*)command;
- (void) setBarcodeTypeMode:(CDVInvokedUrlCommand*)command;
// End JS Callable Functions
@end
