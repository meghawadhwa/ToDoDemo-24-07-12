//
//  TDMenuViewController.h
//  ToDoDemo
//
//  Created by Megha Wadhwa on 27/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDCommon.h"

@interface TDMenuViewController : UITableViewController
@property(nonatomic,retain) NSArray *menuContentsArray;
@property(nonatomic,retain)NSManagedObjectContext *managedObjectContext;
@property(nonatomic,assign) BOOL goingDownByPullUp;
@property(nonatomic,assign) BOOL goingUpByPinchToClose;
@end
