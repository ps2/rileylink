//
//  Log.m
//  GlucoseLink
//
//  Created by Pete Schwamb on 2/22/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Log.h"

@implementation Log

void append(NSString *msg){
  // get path to Documents/somefile.txt
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *path = [documentsDirectory stringByAppendingPathComponent:@"logfile.txt"];
  // create if needed
  if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
    fprintf(stderr,"Creating file at %s",[path UTF8String]);
    [[NSData data] writeToFile:path atomically:YES];
  }
  // append
  NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];
  [handle truncateFileAtOffset:[handle seekToEndOfFile]];
  [handle writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
  [handle closeFile];
}

void _Log(NSString *prefix, const char *file, int lineNumber, const char *funcName, NSString *format,...) {
  va_list ap;
  va_start (ap, format);
  format = [format stringByAppendingString:@"\n"];
  NSDate *time = [NSDate date];
  NSString *msg = [[NSString alloc] initWithFormat:[NSString stringWithFormat:@"%@: %@", time, format] arguments:ap];
  va_end (ap);
  fprintf(stderr,"%s", [msg UTF8String]);
  append(msg);
}
@end