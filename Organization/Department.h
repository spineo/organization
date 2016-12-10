//
//  Department.h
//  
//
//  Created by Stuart Pineo on 12/31/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSManagedObject;

@interface Department : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *department_de;
@end

@interface Department (CoreDataGeneratedAccessors)

- (void)addDepartment_deObject:(NSManagedObject *)value;
- (void)removeDepartment_deObject:(NSManagedObject *)value;
- (void)addDepartment_de:(NSSet *)values;
- (void)removeDepartment_de:(NSSet *)values;

@end
