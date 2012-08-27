//
//  TDItemViewController.h
//  ToDoDemo
//
//  Created by Megha Wadhwa on 27/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDParentViewController.h"

@interface TDItemViewController : TDParentViewController
@property(nonatomic,retain)ToDoList *parentList; 
@property(nonatomic,retain) NSMutableArray *checkedArray;
@property(nonatomic,retain) NSMutableArray *uncheckedArray;
@property(nonatomic,retain) UIImage *overTopImage;
@end
