//
//  ToDoList.h
//  ToDoDemo
//
//  Created by Megha Wadhwa on 27/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ToDoItem;

@interface ToDoList : NSManagedObject

@property (nonatomic, retain) NSString * listName;
@property (nonatomic, retain) NSNumber * doneStatus;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSSet *items;
@end

@interface ToDoList (CoreDataGeneratedAccessors)

- (void)addItemsObject:(ToDoItem *)value;
- (void)removeItemsObject:(ToDoItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
