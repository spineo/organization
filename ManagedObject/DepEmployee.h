//
//  DepEmployee.h
//  
//
//  Created by Stuart Pineo on 12/31/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Department, Employee;

@interface DepEmployee : NSManagedObject

@property (nonatomic, retain) Department *de_department;
@property (nonatomic, retain) Employee *de_employee;

@end
