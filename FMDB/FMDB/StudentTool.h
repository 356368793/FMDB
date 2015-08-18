//
//  StudentTool.h
//  FMDB
//
//  Created by 肖晨 on 15/8/18.
//  Copyright (c) 2015年 肖晨. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Student;

@interface StudentTool : NSObject
+ (void)addStudent:(Student *)student;
+ (NSArray *)students;
@end
