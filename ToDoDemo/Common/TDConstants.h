//
//  TDConstants.h
//  TD
//
//  Created by Megha Wadhwa on 13/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ROW_HEIGHT 55
#define ROW_WIDTH 320
#define SCROLLVIEW_WIDTH 320
#define SCROLLVIEW_HEIGHT 480
#define MINIMUM_PINCH_DISTANCE 100
#define PULL_DOWN_TEXT @"Pull Down To Create Item"
#define RELEASE_AFTER_PULL_TEXT @"Release to add Item"
#define PINCH_OUT_TEXT @"Pinch Out To Create Item"
#define NO_TEXT @""
#define DECELERATION_RATE 3
#define IP @"http://192.168.1.2:3000/to_do_lists.json"   //http://localhost:3000/to_do_lists.json
#define THEME_BLUE @"Blue" 
#define THEME_HEAT_MAP @"heatMap"
#define THEME_MAIN_GRAY @"Grey"
#define DELETION_DELAY 0.1
#define CHECKING_DELAY 0.0
#define DELETING_ROW_ANIMATION_DURATION 0.3 
#define ROWS_SHIFTING_DURATION 0.5
#define BACK_ANIMATION 0.6
#define BACK_ANIMATION_DELAY 0.1

//*** TEMP
#define kListName @"listName"
#define kListId @"id"
#define kDoneStatus @"doneStatus"
#define ADDING_CELL @"Continue..."
#define DONE_CELL @"Done"
#define DUMMY_CELL @"Dummy"
#define COMMITING_CREATE_CELL_HEIGHT 60
#define NORMAL_CELL_FINISHING_HEIGHT 60

//SOUNDS

#define kCheckSound @"button-20.mp3"
#define kUncheckSound @"button-17.mp3"
#define kDeleteSound @"button-27.mp3"
#define kPullDownToCreateSound @"button-11.mp3"
#define kNavigateSound @"button-22.mp3"
#define kDeleteAlertSound @"button-10.mp3"
#define kCheckAlertSound @"button-18.mp3"

#define kPullUpToMoveDownSound @"button-27.mp3"
#define kPullDownToMoveUpSound @"button-27.mp3"

#define kPullUpToClearSound @"button-11.mp3"
#define kPinchOutSound @"button-11.mp3"
#define kPinchInSound @"button-11.mp3"
#define kLongPressSound @"button-11.mp3"