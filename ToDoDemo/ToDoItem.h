//
//  ToDoItem.h
//  ToDoDemo
//
//  Created by Megha Wadhwa on 27/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ToDoList;

@interface ToDoItem : NSManagedObject

@property (nonatomic, retain) NSString * itemName;
@property (nonatomic, retain) NSNumber * doneStatus;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) ToDoList *list;

@end
