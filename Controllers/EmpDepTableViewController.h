//
//  EmpDepTableViewController.h
//  Organization
//
//  Created by Stuart Pineo on 1/8/16.
//  Copyright (c) 2016 Stuart Pineo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Employee.h"

@interface EmpDepTableViewController : UITableViewController

@property (nonatomic, strong) Employee *empObj;

@end
