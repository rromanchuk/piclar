//
//  User+Rest.h
//  explorer
//
//  Created by Ryan Romanchuk on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import "RestUser.h"

@interface User (Rest)
+ (User *)userWithRestUser:(RestUser *)restUser;

@end
