//
//  GlucoseSensorMessage.m
//  GlucoseLink
//
//  Created by Pete Schwamb on 8/14/14.
//  Copyright (c) 2014 Pete Schwamb. All rights reserved.
//

#import "PumpStatusMessage.h"


@interface PumpStatusMessage ()

@end

@implementation PumpStatusMessage

- (instancetype)initWithData:(NSData*)data
{
  self = [super init];
  if (self) {
    self.data = [data subdataWithRange:NSMakeRange(5, data.length-6)];
  }
  return self;
}

- (NSDictionary*) bitBlocks {
  return @{@"sequence": @[@1, @7],
           @"trend": @[@12, @3],
           @"sensor_minute": @[@234, @6],
           @"sensor_hour": @[@227, @5],
           @"sensor_day": @[@267, @5],
           @"sensor_month": @[@260, @4],
           @"sensor_year": @[@248, @8],
           @"bg_h": @[@72, @8],
           @"bg_l": @[@199, @1],
           @"prev_bg_h": @[@80, @8],
           @"prev_bg_l": @[@198, @1],
//sequence: [1,7],
//pump_hour: [19,5],
//pump_minute: [26,6],
//pump_year: [40,8],
//pump_month: [52,4],
//pump_day: [59,5],
//bg_h: [72, 8],
//prev_bg_h: [80, 8],
//insulin_remaining: [101,11],
//sensor_age: [144,8],
//sensor_remaining: [152,8],
           @"active_ins": @[@181, @11]
//prev_bg_l: [198, 1],
//bg_l: [199, 1],
//sensor_hour: [227,5],
//sensor_minute: [234,6],
//sensor_year: [248, 8],
//sensor_month: [260, 4],
//sensor_day: [267,5]
  };
}

- (SensorStatus) sensorStatus {
  NSInteger bgH = [self b:@"bg_h"];
  switch (bgH) {
    case 0:
      return SENSOR_STATUS_MISSING;
    case 1:
      return SENSOR_STATUS_METER_BG_NOW;
    case 2:
      return SENSOR_STATUS_WEAK_SIGNAL;
    case 4:
      return SENSOR_STATUS_WARMUP;
    case 7:
      return SENSOR_STATUS_HIGH_BG;
    case 10:
      return SENSOR_STATUS_LOST;
  }
  if (bgH > 10) {
    return SENSOR_STATUS_OK;
  } else {
    return SENSOR_STATUS_UNKNOWN;
  }
}

- (GlucoseTrend) trend {
  return (GlucoseTrend)[self b:@"trend"];
}

- (NSInteger) glucose {
  if ([self sensorStatus] == SENSOR_STATUS_OK) {
    return ([self b:@"bg_h"] << 1) + [self b:@"bg_l"];
  } else {
    return 0;
  }
}

- (double) activeInsulin {
  return [self b:@"active_ins"] * 0.025;
}

- (NSDate*) measurementTime {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *components = [[NSDateComponents alloc] init];
  [components setYear:[self b:@"sensor_year"]+2000];
  [components setMonth:[self b:@"sensor_month"]];
  [components setDay:[self b:@"sensor_day"]];
  [components setHour:[self b:@"sensor_hour"]];
  [components setMinute:[self b:@"sensor_minute"]];
  [components setSecond:0];
  return [calendar dateFromComponents:components];
}

@end
