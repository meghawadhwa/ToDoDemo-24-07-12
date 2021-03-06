//
//  TDListViewController.h
//  ToDoDemo
//
//  Created by Megha Wadhwa on 26/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDParentViewController.h"
@interface TDListViewController : TDParentViewController <UIActionSheetDelegate,TDPullUpToMoveDownDelegate>
@property(nonatomic,assign) int rowIndexToBeUpdated;
@property(nonatomic,assign) int rowIndexToBeDeleted;
@property(nonatomic,assign) ToDoList *lastVisitedList;
@end
