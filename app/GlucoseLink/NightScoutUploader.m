//
//  NightScoutUploader.m
//  GlucoseLink
//
//  Created by Pete Schwamb on 5/23/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//
// Based on code found in https://github.com/bewest/share2nightscout-bridge

#import "NightScoutUploader.h"
#import "NSString+Hashes.h"
#import "MinimedPacket.h"
#import "PumpStatusMessage.h"
#import "ISO8601DateFormatter.h"
#import "MeterMessage.h"
#import "RileyLinkBLEManager.h"
#import "Config.h"

typedef enum {
  DX_SENSOR_NOT_ACTIVE = 1,
  DX_SENSOR_NOT_CALIBRATED = 5,
  DX_BAD_RF = 12,
} DexcomSensorError;


@interface NightScoutUploader ()

@property (strong, nonatomic) NSMutableArray *entries;
@property (strong, nonatomic) ISO8601DateFormatter *dateFormatter;
@property (nonatomic, assign) NSInteger codingErrorCount;
@property (strong, nonatomic) NSString *pumpSerial;
@property (strong, nonatomic) NSData *lastSGV;
@property (strong, nonatomic) MeterMessage *lastMeterMessage;
@end


@implementation NightScoutUploader

static NSString *defaultNightscoutUploadPath = @"/api/v1/entries.json";
static NSString *defaultNightscoutBatteryPath = @"/api/v1/devicestatus.json";

- (instancetype)init
{
  self = [super init];
  if (self) {
    _entries = [[NSMutableArray alloc] init];
    _dateFormatter = [[ISO8601DateFormatter alloc] init];
    _dateFormatter.includeTime = YES;
    _dateFormatter.useMillisecondPrecision = YES;
    _dateFormatter.defaultTimeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(packetReceived:)
                                                 name:RILEY_LINK_EVENT_PACKET_RECEIVED
                                               object:nil];

  }
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)packetReceived:(NSNotification*)notification {
  NSDictionary *attrs = notification.userInfo;
  MinimedPacket *packet = attrs[@"packet"];
  [self addPacket:packet];
}

//var DIRECTIONS = {
//NONE: 0
//  , DoubleUp: 1
//  , SingleUp: 2
//  , FortyFiveUp: 3
//  , Flat: 4
//  , FortyFiveDown: 5
//  , SingleDown: 6
//  , DoubleDown: 7
//  , 'NOT COMPUTABLE': 8
//  , 'RATE OUT OF RANGE': 9
//};


- (NSString*)trendToDirection:(GlucoseTrend)trend {
  switch (trend) {
    case GLUCOSE_TREND_NONE:
      return @"";
    case GLUCOSE_TREND_UP:
      return @"SingleUp";
    case GLUCOSE_TREND_DOUBLE_UP:
      return @"DoubleUp";
    case GLUCOSE_TREND_DOWN:
      return @"SingleDown";
    case GLUCOSE_TREND_DOUBLE_DOWN:
      return @"DoubleDown";
    default:
      return @"NOT COMPUTABLE";
      break;
  }
}

//  Entries [ { sgv: 375,
//    date: 1432421525000,
//    dateString: '2015-05-23T22:52:05.000Z',
//    trend: 1,
//    direction: 'DoubleUp',
//    device: 'share2',
//    type: 'sgv' } ]

- (void)addPacket:(MinimedPacket*)packet {
  NSDictionary *entry = nil;
  
  if (![packet isValid]) {
    return;
  }
  
  if ([packet packetType] == PACKET_TYPE_PUMP && [packet messageType] == MESSAGE_TYPE_PUMP_STATUS) {
    PumpStatusMessage *msg = [[PumpStatusMessage alloc] initWithData:packet.data];
    NSNumber *epochTime = [NSNumber numberWithDouble:[msg.measurementTime timeIntervalSince1970] * 1000];
    
    if (![packet.address isEqualToString:[[Config sharedInstance] pumpID]]) {
      NSLog(@"Dropping mysentry packet for pump: %@", packet.address);
      return;
    }
    
    NSInteger glucose = msg.glucose;
    switch ([msg sensorStatus]) {
      case SENSOR_STATUS_HIGH_BG:
        glucose = 401;
        break;
      case SENSOR_STATUS_WEAK_SIGNAL:
        glucose = DX_BAD_RF;
        break;
      case SENSOR_STATUS_METER_BG_NOW:
        glucose = DX_SENSOR_NOT_CALIBRATED;
        break;
      case SENSOR_STATUS_LOST:
        glucose = DX_SENSOR_NOT_ACTIVE;
        break;
      default:
        break;
    }
    
    entry =
      @{@"date": epochTime,
        @"dateString": [self.dateFormatter stringFromDate:msg.measurementTime],
        @"sgv": [NSNumber numberWithLong:glucose],
        @"direction": [self trendToDirection:msg.trend],
        @"device": @"RileyLink",
        @"iob": [NSNumber numberWithFloat:msg.activeInsulin],
        @"type": @"sgv"
        };
  } else if ([packet packetType] == PACKET_TYPE_METER) {
    MeterMessage *msg = [[MeterMessage alloc] initWithData:packet.data];
    msg.dateReceived = [NSDate date];
    NSTimeInterval seconds = [msg.dateReceived timeIntervalSince1970];
    NSNumber *epochTime = [NSNumber numberWithLongLong:seconds * 1000];
    entry =
    @{@"date": epochTime,
      @"dateString": [self.dateFormatter stringFromDate:msg.dateReceived],
      @"mbg": [NSNumber numberWithLong:msg.glucose],
      @"device": @"Contour Next Link",
      @"type": @"mbg"
      };
    
    // Skip duplicates
    if (_lastMeterMessage &&
        [msg.dateReceived timeIntervalSinceDate:_lastMeterMessage.dateReceived] &&
        msg.glucose == _lastMeterMessage.glucose) {
      entry = nil;
    } else {
      _lastMeterMessage = msg;
    }
  }
  if (entry) {
    [self.entries addObject:entry];
    //NSLog(@"Added entry: %@", entry);
    [self flushEntries];
  }
}

- (void) flushEntries {
  NSArray *inFlightEntries = self.entries;
  self.entries = [[NSMutableArray alloc] init];
  [self reportToNightScout:inFlightEntries completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    if (httpResponse.statusCode != 200) {
      NSLog(@"Requeuing %d sgv entries: %@", inFlightEntries.count, error);
      [self.entries addObjectsFromArray:inFlightEntries];
    } else {
      NSString *resp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      NSLog(@"Submitted %d entries to nightscout: %@", inFlightEntries.count, resp);
    }
  }];
}

- (void) reportToNightScout:(NSArray*)entries
completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
  NSURLComponents *components = [[NSURLComponents alloc] init];
  NSURL *baseURL = [NSURL URLWithString:self.endpoint];
  components.scheme = @"https";
  components.host = baseURL.host;
  components.path = [baseURL.path stringByAppendingString:defaultNightscoutUploadPath];
  
  NSMutableURLRequest *request = [[NSURLRequest requestWithURL:components.URL] mutableCopy];
  NSError *error;
  NSData *sendData = [NSJSONSerialization dataWithJSONObject:entries options:NSJSONWritingPrettyPrinted error:&error];
  NSString *jsonPost = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
  NSLog(@"Posting to %@, %@", components.URL, jsonPost);
  [request setHTTPMethod:@"POST"];
  
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [request setValue:[self.APISecret sha1] forHTTPHeaderField:@"api-secret"];
  
  [request setHTTPBody: sendData];
  
  [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:completionHandler] resume];
}

@end
