//
//  SLRESTContract.m
//  SLRemoting
//
//  Created by Michael Schoonmaker on 6/6/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import "SLRESTContract.h"

NSString *SLRESTContractDefaultVerb = @"POST";

@interface SLRESTContractItem()

@property (readwrite, nonatomic, copy) NSString *pattern;
@property (readwrite, nonatomic, copy) NSString *verb;

@end

@interface SLRESTContract()

@property (readwrite, nonatomic) NSDictionary *dict;

@end

@implementation SLRESTContractItem

+ (instancetype)itemWithPattern:(NSString *)pattern {
    return [[self alloc] initWithPattern:pattern];
}

- (instancetype)initWithPattern:(NSString *)pattern {
    return [self initWithPattern:pattern verb:@"POST"];
}

+ (instancetype)itemWithPattern:(NSString *)pattern
                           verb:(NSString *)verb {
    return [[self alloc] initWithPattern:pattern verb:verb];
}

- (instancetype)initWithPattern:(NSString *)pattern
                           verb:(NSString *)verb {
    self = [super init];
    
    if (self) {
        self.pattern = pattern;
        self.verb = verb;
    }
    
    return self;
}

@end

@implementation SLRESTContract

+ (instancetype)contract {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.dict = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)addItem:(SLRESTContractItem *)item
      forMethod:(NSString *)method {
    NSParameterAssert(item);
    NSParameterAssert(method);
    
    ((NSMutableDictionary *)self.dict)[method] = item;
}

- (NSString *)urlForMethod:(NSString *)method
                parameters:(NSDictionary *)parameters {
    NSParameterAssert(method);
    
    NSString *pattern = [self patternForMethod:method];
    
    if (pattern) {
        return [self urlWithPattern:pattern parameters:parameters];
    } else {
        return [self urlForMethodWithoutItem:method];
    }
}

- (NSString *)verbForMethod:(NSString *)method {
    NSParameterAssert(method);
    
    SLRESTContractItem *item = (SLRESTContractItem *)self.dict[method];
    
    return item ? item.verb : @"POST";
}

- (NSString *)urlForMethodWithoutItem:(NSString *)method {
    return [method stringByReplacingOccurrencesOfString:@"." withString:@"/"];
}

- (NSString *)patternForMethod:(NSString *)method {
    NSParameterAssert(method);
    
    SLRESTContractItem *item = (SLRESTContractItem *)self.dict[method];
    
    return item ? item.pattern : nil;
}

- (NSString *)urlWithPattern:(NSString *)pattern
                  parameters:(NSDictionary *)parameters {
    NSParameterAssert(pattern);
    
    if (!parameters) {
        return pattern;
    }
    
    NSString __block *url = pattern;
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        url = [url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@":%@", key] withString:[NSString stringWithFormat:@"%@", obj]];
    }];
    
    return url;
}

@end
