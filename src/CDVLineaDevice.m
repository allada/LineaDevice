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
//  CDVLineaDevice.m
//
//  Created by Nathan Bruer.
//

#import "CDVLineaDevice.h"

@implementation CDVLineaDevice
@synthesize callbackId;

- (CDVPlugin*) initWithWebView:(UIWebView*)theWebView {
    LOG(@"initing Linea Device Plugin");
    self = [super initWithWebView:theWebView];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(disconnectLinea:)
        name:UIApplicationWillResignActiveNotification
        object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(connectLinea:)
     name:UIApplicationDidBecomeActiveNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(disconnectLinea:)
     name:UIApplicationWillTerminateNotification
     object:nil];
    [self connectLinea: nil];
    return self;
}

- (void) connectLinea:(NSNotification *)notification {
    LOG(@"Connecting to linea device");
    if(linea == nil)
        linea = [DTDevices sharedDevice];
	[linea addDelegate:self];
	[linea connect];
}
- (void) disconnectLinea:(NSNotification *)notification {
    LOG(@"Disconnecting from linea device");
    [linea disconnect];
    [linea removeDelegate:self];
}

// End Functions extended over from ViewController
/**
 * Definer micros to save code space on argument checking.
 */
#ifndef BEGIN_ARGCHECKWRAPPER
#define BEGIN_ARGCHECKWRAPPER(required_args, lineaConnectedCheck) \
    int i; \
    NSString* localCallbackId = command.callbackId; \
    NSArray* arguments = command.arguments; \
    CDVPluginResult* pluginResult = nil; \
    NSString* javaScript = nil; \
    NSMutableArray *returnArgs = [[NSMutableArray alloc] init]; \
    @try { \
        if (lineaConnectedCheck && [linea connstate] != CONN_CONNECTED) { \
            [NSException raise:@"NoDevice" format:@"Linea Device is currently not connected"]; \
        } \
        if([arguments count] < required_args) { \
            [NSException raise:@"InvalidArgument" format:@"Function requires %i arguments and %i arguments passed",required_args, [arguments count]]; \
        } \
        for (i=0;i<required_args;i++) { \
            if([arguments objectAtIndex: i] == nil) { \
                [NSException raise:@"InvalidArgument" format:@"Argument %i cannot be null",i]; \
            } \
        }
#define END_ARGCHECKWRAPPER \
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:returnArgs]; \
        javaScript = [pluginResult toSuccessCallbackString:localCallbackId]; \
    } @catch (id exception){ \
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_JSON_EXCEPTION messageAsString:[exception reason]]; \
        javaScript = [pluginResult toErrorCallbackString:localCallbackId]; \
    } \
    [self writeJavascript:[NSString stringWithFormat:@"window.setTimeout(function(){%@;},0);", javaScript]];
#define IF_NULLOBJ(item) item ? item : [NSNull null]

#endif
// Begin callable functions from javascript
/*
 * The following functions are called from the plugin handler of PhoneGap. These functions pass *arguments from the javascript and any options along with it.
 * *arguments is an array of all arguments the javascript function passed. arguments[0] is always the localCallbackId and all subsiquent items is the actual data.
 */
- (void) configureAllSettings:(CDVInvokedUrlCommand*)command {
    BEGIN_ARGCHECKWRAPPER(0, true)
    LOG(@"Configuring");
    int i=0;
    NSDictionary *options = [arguments objectAtIndex:0];
    if(options){
        if([options objectForKey:@"SCAN_BEEP"] && [options objectForKey:@"SCAN_BEEP_ENABLED"]){
            NSArray *sounds = [options objectForKey:@"SCAN_BEEP"];
            int count = [sounds count];
            int *newAry = malloc(sizeof(int) * count);
            for(;i<count;i++){
                newAry[i] = [[sounds objectAtIndex:i] intValue];
            }
            [linea barcodeSetScanBeep:(bool) [[options objectForKey:@"SCAN_BEEP_ENABLED"] boolValue] volume:100 beepData:newAry length:sizeof(int) * count error:nil];
            free(newAry);
        }

        if([options objectForKey:@"SCAN_MODE"]){
            [linea barcodeSetScanMode:[[options objectForKey:@"SCAN_MODE"] intValue] error:nil];
        }
        if([options objectForKey:@"BUTTON_ENABLED"]){
            [linea barcodeSetScanButtonMode:[[options objectForKey:@"BUTTON_ENABLED"] intValue] error:nil];
        }
        if([options objectForKey:@"MS_MODE"]){
            [linea msSetCardDataMode:[[options objectForKey:@"MS_MODE"] intValue] error:nil];
        }
        if([options objectForKey:@"BARCODE_TYPE"]){
            [linea barcodeSetTypeMode:[[options objectForKey:@"BARCODE_TYPE"] intValue] error:nil];
        }
        if([options objectForKey:@"CHARGING"]){
            [linea setCharging:[[options objectForKey:@"CHARGING"] boolValue] error:nil];
        }
    }
    END_ARGCHECKWRAPPER
}
/**
 * Plays a sound.
 * @arguments[1] int        Volume (Currently the Linea Device does not support this)
 * @arguments[2] array      Array of frequentcy and durations. [freqency,duration,frequency,duration, ...]
 */
- (void) playSound:(CDVInvokedUrlCommand*)command {
    BEGIN_ARGCHECKWRAPPER(2, true)
    NSArray *sounds = [arguments objectAtIndex:1];
    int count = [sounds count];
    int *newAry = malloc(sizeof(int) * count);
    int i=0;
    for(;i<(count > 10 ? 10 : count);i++){
        newAry[i] = [[sounds objectAtIndex:i] intValue];
    }
    [linea playSound:(int) [[arguments objectAtIndex:0] intValue] beepData:newAry length:sizeof(int) * (count > 10 ? 10 : count) error:nil];
    free(newAry);
    if(count > 10){
        [NSException raise:@"InvalidArgument" format:@"You may only send 5 sounds though this function at a time, you tried to send %i. The remaining sounds where truncated.", count];
    }
    END_ARGCHECKWRAPPER
}
/**
 * Starts the lazer.
 */
- (void) startScan:(CDVInvokedUrlCommand*)command {
    BEGIN_ARGCHECKWRAPPER(0, true)
    LOG(@"Started Scan");
    [linea barcodeStartScan:nil];
    END_ARGCHECKWRAPPER
}
/**
 * Stops the lazer.
 */
- (void) stopScan:(CDVInvokedUrlCommand*)command {
    BEGIN_ARGCHECKWRAPPER(0, true)
    LOG(@"Stopped Scan");
    [linea barcodeStopScan:nil];
    END_ARGCHECKWRAPPER
}
/**
 * Weather the scan engine should work in persistent scan mode or single scan mode.
 * @arguments[0] int        Integer value of MODE_SINGLE_SCAN or MODE_MULTI_SCAN
 */
- (void) setScanMode:(CDVInvokedUrlCommand*)command {
    BEGIN_ARGCHECKWRAPPER(1, true)
    LOG(@"Set Scan Mode");
    [linea barcodeSetScanMode:(int) [[arguments objectAtIndex:0] intValue] error:nil];
    END_ARGCHECKWRAPPER
}
/**
 * Sets the beep sound when a barcode is scanned.
 * @arguments[0] boolean    Enabled or not.
 * @arguments[1] int        Volume (currently not supported by linea device)
 * @arguments[2] array      Array of frequentcy and durations. [freqency,duration,frequency,duration, ...]
 */
- (void) setScanBeep:(CDVInvokedUrlCommand*)command {
    BEGIN_ARGCHECKWRAPPER(3, true)
    LOG(@"Set Scan Beep");
    NSArray *sounds = [arguments objectAtIndex:2];
    int count = [sounds count];
    int *newAry = malloc(sizeof(int) * count);
    int i=0;
    for(;i<count;i++){
        newAry[i] = [[sounds objectAtIndex:i] intValue];
    }
    [linea barcodeSetScanBeep:(bool) [[arguments objectAtIndex:0] boolValue] volume:(int) [[arguments objectAtIndex:1] intValue] beepData:newAry length:sizeof(int) * count error:nil];
    free(newAry);
    END_ARGCHECKWRAPPER
}
/**
 * Enables the button for scanning or not
 * @arguments[0] int        Int value of BUTTON_DISABLED or BUTTON_ENABLED
 */
- (void) setScanButtonMode:(CDVInvokedUrlCommand*)command {
    BEGIN_ARGCHECKWRAPPER(1, true)
    LOG(@"Set Scan Button Mode");
    [linea barcodeSetScanButtonMode:(int) [[arguments objectAtIndex:0] intValue] error:nil];
    END_ARGCHECKWRAPPER
}
/**
 * Sets how to read the card.
 * @arguments[0] int    Int value for MS_PROCESSED_CARD_DATA or MS_RAW_CARD_DATA
 */
- (void) setMSCardDataMode:(CDVInvokedUrlCommand*)command {
    LOG(@"Set MS Card Data Mode");
    BEGIN_ARGCHECKWRAPPER(1, true)
    [linea msSetCardDataMode:(int) [[arguments objectAtIndex:0] intValue] error:nil];
    END_ARGCHECKWRAPPER
}
/**
 * Sets weather to read barcode as extended barcode types
 * @arguments[0] int    Int value for BARCODE_TYPE_DEFAULT or BARCODE_TYPE_EXTENDED
 */
- (void) setBarcodeTypeMode:(CDVInvokedUrlCommand*)command {
    BEGIN_ARGCHECKWRAPPER(1, true)
    LOG(@"Set Barcode Type Mode");
    [linea barcodeSetTypeMode:(int) [[arguments objectAtIndex:0] intValue] error:nil];
    END_ARGCHECKWRAPPER
}
/**
 * Gets current scan button mode
 */
- (void) getScanButtonMode:(CDVInvokedUrlCommand*)command {
    BEGIN_ARGCHECKWRAPPER(0, true)
    int mode;
    [linea barcodeGetScanButtonMode:&mode error:nil];
    [returnArgs addObject:[NSNumber numberWithInt:mode]];
    END_ARGCHECKWRAPPER
}
/**
 * Gets current scan mode
 */
- (void) getScanMode:(CDVInvokedUrlCommand*)command {
    BEGIN_ARGCHECKWRAPPER(0, true)
    int mode;
    [linea barcodeGetScanMode:&mode error:nil];
    [returnArgs addObject:[NSNumber numberWithInt:mode]];
    END_ARGCHECKWRAPPER
}
/**
 * Gets Battery Capacity in percent
 */
- (void) getBatteryCapacity:(CDVInvokedUrlCommand*)command {
    BEGIN_ARGCHECKWRAPPER(0, true)
    int cap;
    float vol;
    [linea getBatteryCapacity:&cap voltage:&vol error:nil];
    [returnArgs addObject:[NSNumber numberWithInt:cap]];
    END_ARGCHECKWRAPPER
}
/**
 * Gets Battery Voltage
 */
- (void) getBatteryVoltage:(CDVInvokedUrlCommand*)command {
    BEGIN_ARGCHECKWRAPPER(0, true)
    int cap;
    float vol;
    [linea getBatteryCapacity:&cap voltage:&vol error:nil];
    [returnArgs addObject:[NSNumber numberWithFloat:vol]];
    END_ARGCHECKWRAPPER
}
/**
 * Get Charging
 */
- (void) getCharging:(CDVInvokedUrlCommand*)command {
    BEGIN_ARGCHECKWRAPPER(0, true)
    BOOL charging;
    [linea getCharging:&charging error:nil];
    [returnArgs addObject:[NSNumber numberWithBool:charging]];
    END_ARGCHECKWRAPPER
}
/**
 * Set Charging
 */
- (void) setCharging:(CDVInvokedUrlCommand*)command {
    BEGIN_ARGCHECKWRAPPER(1, true)
    LOG(@"Set Charge Mode");
    [linea setCharging:[[arguments objectAtIndex:0] boolValue] error:nil];
    END_ARGCHECKWRAPPER
}
/**
 * Get Financial Info From Credit Card
 */
- (void) msProcessFinancialCard:(CDVInvokedUrlCommand*)command {
    BEGIN_ARGCHECKWRAPPER(2, true)
    NSString *track1 = [arguments objectAtIndex:0];
    NSString *track2 = [arguments objectAtIndex:1];
    NSDictionary *data = [linea msProcessFinancialCard:track1 track2:track2];
    [returnArgs addObject:data];
    END_ARGCHECKWRAPPER
}
/**
 * Get Barcode Type Mode
 */
- (void) getBarcodeTypeMode:(CDVInvokedUrlCommand*)command {
    BEGIN_ARGCHECKWRAPPER(0, true)
    int mode;
    [linea barcodeGetTypeMode:&mode error:nil];
    [returnArgs addObject:[NSNumber numberWithInt:mode]];
    END_ARGCHECKWRAPPER
}
- (void) getConnectionState:(CDVInvokedUrlCommand*)command {
    BEGIN_ARGCHECKWRAPPER(0, false)
    [returnArgs addObject:[NSNumber numberWithInt:lineaConnectionState]];
    END_ARGCHECKWRAPPER
}
/**
 * Barcode Type 2 Text
 */
- (void) barcodeType2Text:(CDVInvokedUrlCommand*)command {
    BEGIN_ARGCHECKWRAPPER(1, true)
    [returnArgs addObject:[linea barcodeType2Text:[[arguments objectAtIndex:0] intValue]]];
    END_ARGCHECKWRAPPER
}


// Non-device driven functions
/**
 * Sets which function will be used to monitor events from linea device.
 */
- (void) monitor:(CDVInvokedUrlCommand*)command {
    self.callbackId = command.callbackId;
    BEGIN_ARGCHECKWRAPPER(0, false)
    	[returnArgs addObject:@"connectionState"];
    	[returnArgs addObject:[NSNumber numberWithInt:lineaConnectionState]];
    	pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:returnArgs];
    	[pluginResult setKeepCallbackAsBool: true];
    	javaScript = [pluginResult toSuccessCallbackString:localCallbackId];
	} @catch (id exception){
    	pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_JSON_EXCEPTION messageAsString:[exception reason]];
    	javaScript = [pluginResult toErrorCallbackString:localCallbackId];
	}
	[self writeJavascript:[NSString stringWithFormat:@"window.setTimeout(function(){%@;},0);", javaScript]];
}
/**
 * Unsets the function used to monitor events from the linea device.
 */
- (void) unmonitor:(CDVInvokedUrlCommand*)command {
    BEGIN_ARGCHECKWRAPPER(0, true)
    self.callbackId = nil;
    END_ARGCHECKWRAPPER
}
// End callabale functions from javascript
#ifndef BEGIN_JSINJECTWARPPER
#define BEGIN_JSINJECTWARPPER \
    if(self.callbackId != nil){ \
        NSMutableArray *returnArgs = [[NSMutableArray alloc] init];
#define END_JSINJECTWRAPPER \
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:returnArgs]; \
        [result setKeepCallbackAsBool:true]; \
        [super writeJavascript:[result toSuccessCallbackString:self.callbackId]]; \
    }
#define NIL2EMPTYSTR(str) str == nil?@"":str
#endif



// Begin called functions from Linea Device
/**
 * Event fired when barcode is scanned
 * @returns [(string) 'barcodeData', (string) barcode, (int) barcodeType]
 */
- (void)barcodeData:(NSString *)barcode type:(int)type {
    BEGIN_JSINJECTWARPPER
    NSNumber *objType = [NSNumber numberWithInt:type]; // Convert to object because int is not an object and NSArray requires objects.
    [returnArgs addObject:@"barcodeData"];
    [returnArgs addObject:NIL2EMPTYSTR(barcode)];
    [returnArgs addObject:objType];
    END_JSINJECTWRAPPER
}
/**
 * Event fired when card is swipped.
 * @returns [(string) 'magenticCardData', (string) track1, (string) track2, (string) track3]
 */
- (void)magneticCardData:(NSString *)track1 track2:(NSString *)track2 track3:(NSString *)track3 {
    BEGIN_JSINJECTWARPPER
    [returnArgs addObject:@"magneticCardData"];
    [returnArgs addObject:NIL2EMPTYSTR(track1)];
    [returnArgs addObject:NIL2EMPTYSTR(track2)];
    [returnArgs addObject:NIL2EMPTYSTR(track3)];
    END_JSINJECTWRAPPER
}
/**
 * Event fired when card is swiped and raw mode is enabled.
 * @returns [(string) 'magneticCardRawData', (string) rawData]
 */
- (void)magneticCardRawData:(NSData *)tracks {
    BEGIN_JSINJECTWARPPER
    [returnArgs addObject:@"magneticCardRawData"];
    [returnArgs addObject:[NSString stringWithUTF8String:[tracks bytes]]];
    END_JSINJECTWRAPPER
}
/**
 * Notification sent when JIS I & II magnetic card is successfuly read.
 * @returns [(string) 'magneticJISCardData', (string) data]
 */
- (void)magneticJISCardData:(NSString *) data{
    BEGIN_JSINJECTWARPPER
    [returnArgs addObject:@"magneticJISCardData"];
    [returnArgs addObject:data];
    END_JSINJECTWRAPPER
}
-(void)smartCardInserted:(SC_SLOTS)slot{
    BEGIN_JSINJECTWARPPER
    [returnArgs addObject:@"smartCardInserted"];
    [returnArgs addObject:[NSNumber numberWithInt:slot]];
    END_JSINJECTWRAPPER
}
-(void)smartCardRemoved:(SC_SLOTS)slot{
    BEGIN_JSINJECTWARPPER
    [returnArgs addObject:@"smartCardRemoved"];
    [returnArgs addObject:[NSNumber numberWithInt:slot]];
    END_JSINJECTWRAPPER
}
-(void)barcodeData:(NSString *)barcode isotype:(NSString *)isotype{
    BEGIN_JSINJECTWARPPER
    [returnArgs addObject:@"barcodeDataIsoType"];
    [returnArgs addObject:barcode];
    [returnArgs addObject:isotype];
    END_JSINJECTWRAPPER
}
-(void)PINEntryCompleteWithError:(NSError *)error{
    BEGIN_JSINJECTWARPPER
    [returnArgs addObject:@"PINEntryCompleteWithError"];
    [returnArgs addObject:[error localizedDescription]];
    END_JSINJECTWRAPPER
}
/**
 * Notification sent when paper's paper sensor changes.
 */
-(void)paperStatus:(BOOL)present{
    BEGIN_JSINJECTWARPPER
    [returnArgs addObject:@"paperStatus"];
    [returnArgs addObject:[NSNumber numberWithBool:present]];
    END_JSINJECTWRAPPER
}
-(void)rfCardDetected: (int) cardIndex info: (DTRFCardInfo *) info{
    BEGIN_JSINJECTWARPPER
    [returnArgs addObject:@"rfCardDetected"];
    [returnArgs addObject:[NSNumber numberWithBool:cardIndex]];
    NSDictionary *dict = [NSDictionary dictionary];
    [dict setValue:[NSNumber numberWithInt:[info type]] forKey:@"type"];
    [dict setValue:[info typeStr] forKey:@"typeStr"];
    [dict setValue:[info UID] forKey:@"UID"];
    [dict setValue:[NSNumber numberWithInt:[info ATQA]] forKey:@"ATQA"];
    [dict setValue:[NSNumber numberWithInt:[info SAK]] forKey:@"SAK"];
    [dict setValue:[NSNumber numberWithInt:[info AFI]] forKey:@"AFI"];
    [dict setValue:[NSNumber numberWithInt:[info DSFID]] forKey:@"DSFID"];
    [dict setValue:[NSNumber numberWithInt:[info blockSize]] forKey:@"blockSize"];
    [dict setValue:[NSNumber numberWithInt:[info nBlocks]] forKey:@"nBlocks"];
    [returnArgs addObject:dict];
    END_JSINJECTWRAPPER
}
-(void)bluetoothDeviceConnected:(NSString *)btAddress{
    BEGIN_JSINJECTWARPPER
    [returnArgs addObject:@"bluetoothDeviceConnected"];
    [returnArgs addObject:btAddress];
    END_JSINJECTWRAPPER
}
-(void)bluetoothDeviceDisconnected:(NSString *)btAddress{
    BEGIN_JSINJECTWARPPER
    [returnArgs addObject:@"bluetoothDeviceDisconnected"];
    [returnArgs addObject:btAddress];
    END_JSINJECTWRAPPER
}
-(void)bluetoothDiscoverComplete:(BOOL)success{
    BEGIN_JSINJECTWARPPER
    [returnArgs addObject:@"bluetoothDiscoverComplete"];
    [returnArgs addObject:[NSNumber numberWithBool:success]];
    END_JSINJECTWRAPPER
}
-(void)bluetoothDeviceDiscovered:(NSString *)btAddress name:(NSString *)btName:(BOOL)success{
    BEGIN_JSINJECTWARPPER
    [returnArgs addObject:@"bluetoothDeviceDiscovered"];
    [returnArgs addObject:btAddress];
    [returnArgs addObject:btName];
    [returnArgs addObject:[NSNumber numberWithBool:success]];
    END_JSINJECTWRAPPER
}
-(void)rfCardRemoved: (int) cardIndex{
    BEGIN_JSINJECTWARPPER
    [returnArgs addObject:@"rfCardRemoved"];
    [returnArgs addObject:[NSNumber numberWithBool:cardIndex]];
    END_JSINJECTWRAPPER
}
/**
 * Event fired when button is pressed
 * @returns [(string) 'buttonPressed', (int) whichButton]
 */
- (void)deviceButtonPressed:(int)which {
    LOG(@"Button pressed");
    BEGIN_JSINJECTWARPPER
    NSNumber *objWhich = [NSNumber numberWithInt:which]; // Convert to object because int is not an object and NSArray requires objects.
    [returnArgs addObject:@"buttonPressed"];
    [returnArgs addObject:objWhich];
    END_JSINJECTWRAPPER
}
/**
 * Event fired when button is released
 * @returns [(string) 'buttonReleased', (int) whichButton]
 */
- (void)deviceButtonReleased:(int)which {
    LOG(@"Button Released");
    BEGIN_JSINJECTWARPPER
    NSNumber *objWhich = [NSNumber numberWithInt:which]; // Convert to object because int is not an object and NSArray requires objects.
    [returnArgs addObject:@"buttonReleased"];
    [returnArgs addObject:objWhich];
    END_JSINJECTWRAPPER
}
/**
 * Event fired when a feature gets enabled or disabled.
 * @returns [(string) 'featureSupported', (int) feature, (int) value]
 */
- (void)deviceFeatureSupported: (int) feature value:(int) value{
    LOG(@"Button Released");
    BEGIN_JSINJECTWARPPER
    [returnArgs addObject:@"featureSupported"];
    [returnArgs addObject:[NSNumber numberWithInt:feature]];
    [returnArgs addObject:[NSNumber numberWithInt:value]];
    END_JSINJECTWRAPPER
}
/**
 * Event fired when device connection state changed.
 * @returns [(string) 'buttonReleased', (int) state]
 */
-(void)connectionState:(int)state {
    LOG(@"Status Changed: %i", state);
    lineaConnectionState = state;
    if (state == CONN_CONNECTED) {
        [linea msEnable:nil];
    }
    BEGIN_JSINJECTWARPPER
    NSNumber *objState = [NSNumber numberWithInt:state]; // Convert to object because int is not an object and NSArray requires objects.
    [returnArgs addObject:@"connectionState"];
    [returnArgs addObject:objState];
    END_JSINJECTWRAPPER
}
// End called functions from Linea Device
@end
