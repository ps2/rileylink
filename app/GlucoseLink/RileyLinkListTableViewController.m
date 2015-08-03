//
//  RileyLinkListTableViewController.m
//  RileyLink
//
//  Created by Pete Schwamb on 7/27/15.
//  Copyright (c) 2015 Pete Schwamb. All rights reserved.
//

#import "RileyLinkListTableViewController.h"
#import "SWRevealViewController.h"
#import "RileyLinkBLEManager.h"
#import "RileyLinkTableViewCell.h"
#import "RileyLinkBLEDevice.h"
#import "AppDelegate.h"
#import "RileyLinkDeviceViewController.h"

@interface RileyLinkListTableViewController () {
  NSMutableArray *rileyLinkRecords;
  NSMutableDictionary *recordsById;
  NSMutableDictionary *devicesById;
  IBOutlet UIBarButtonItem *menuButton;
}

@end

@implementation RileyLinkListTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  self.managedObjectContext = appDelegate.managedObjectContext;
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(listUpdated:)
                                               name:RILEY_LINK_EVENT_LIST_UPDATED
                                             object:nil];
  
  if (self.revealViewController != nil) {
    menuButton.target = self.revealViewController;
    [menuButton setAction:@selector(revealToggle:)];
    [self.view addGestureRecognizer: self.revealViewController.panGestureRecognizer];
  }
  
  [self loadRecordsFromDB];
  [self processVisibleDevices];
}

- (void)processVisibleDevices {
  devicesById = [NSMutableDictionary dictionary];
  
  for (RileyLinkBLEDevice *device in [[RileyLinkBLEManager sharedManager] rileyLinkList]) {
    devicesById[device.peripheralId] = device;
    
    RileyLinkRecord *existingRecord = recordsById[device.peripheralId];
    
    if (existingRecord == NULL) {
      // Haven't seen this device before; add it to Core Data
      RileyLinkRecord *record = [NSEntityDescription
                                  insertNewObjectForEntityForName:@"RileyLinkRecord"
                                  inManagedObjectContext:self.managedObjectContext];
      record.name = device.name;
      record.peripheralId = device.peripheralId;
      record.firstSeenAt = [NSDate date];
      record.autoConnect = @NO;
      recordsById[device.peripheralId] = record;
      [rileyLinkRecords addObject: record];
    } else {
      // Have seen it; update name
      existingRecord.name = device.name;
    }
  }
  NSError *error;
  if (![self.managedObjectContext save:&error]) {
    NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
  }
  [self.tableView reloadData];
}

- (void)listUpdated:(NSNotification *)notification {
  [self processVisibleDevices];
}

- (void)loadRecordsFromDB {
  rileyLinkRecords = [NSMutableArray array];
  recordsById = [NSMutableDictionary dictionary];
  
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"firstSeenAt" ascending:YES];
  [fetchRequest setSortDescriptors:@[sortDescriptor1]];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"RileyLinkRecord"
                                            inManagedObjectContext:self.managedObjectContext];
  [fetchRequest setEntity:entity];
  NSError *error;
  NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  for (RileyLinkRecord *record in fetchedObjects) {
    NSLog(@"Loaded: %@ from db", record.name);
    recordsById[record.peripheralId] = record;
    [rileyLinkRecords addObject:record];
  }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // Return the number of rows in the section.
  return [rileyLinkRecords count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  RileyLinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rileylink" forIndexPath:indexPath];
  RileyLinkRecord *record = rileyLinkRecords[indexPath.row];
  cell.name = record.name;
  cell.autoConnect = [record.autoConnect boolValue];
  
  RileyLinkBLEDevice *device = devicesById[record.peripheralId];
  if (device) {
    cell.visible = YES;
    cell.RSSI = device.RSSI;
  } else {
    cell.visible = NO;
    cell.RSSI = nil;
  }
  return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  RileyLinkDeviceViewController *controller = [segue destinationViewController];
  NSIndexPath *ip = [self.tableView indexPathForSelectedRow];
  RileyLinkRecord *record = rileyLinkRecords[ip.row];
  controller.rlRecord = record;
  controller.rlDevice = devicesById[record.peripheralId];
  controller.managedObjectContext = self.managedObjectContext;
}

@end
