//
//  TweetSendLocation.m
//  Coding_iOS
//
//  Created by Kevin on 3/11/15.
//  Copyright (c) 2015 Coding. All rights reserved.
//

#import "TweetSendLocation.h"
#import "Login.h"
#import "User.h"

NSString * const kBaiduAPIPlacePath = @"/place/v2/search";
NSString * const kBaiduAPIGeosearchPath = @"/geosearch/v3/nearby";
NSString * const kBaiduAPIGeosearchPathCreate = @"/geodata/v3/poi/create";

NSString * const kBaiduAPIUrl = @"http://api.map.baidu.com";


#pragma mark - AFNet
static NSString * const kCodingCharactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";
static NSString * CodingPercentEscapedQueryStringKeyFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    static NSString * const kCodingCharactersToLeaveUnescapedInQueryStringPairKey = @"[].";
    
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, (__bridge CFStringRef)kCodingCharactersToLeaveUnescapedInQueryStringPairKey, (__bridge CFStringRef)kCodingCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}
static NSString * CodingPercentEscapedQueryStringValueFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)kCodingCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}
extern NSArray * CodingQueryStringPairsFromDictionary(NSDictionary *dictionary);
extern NSArray * CodingQueryStringPairsFromKeyAndValue(NSString *key, id value);



@interface CodingQueryStringPair : NSObject
@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (id)initWithField:(id)field value:(id)value;

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding;
@end

@implementation CodingQueryStringPair

- (id)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.field = field;
    self.value = value;
    
    return self;
}

//NSUTF8StringEncoding
- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return CodingPercentEscapedQueryStringKeyFromStringWithEncoding([self.field description], stringEncoding);
    } else {
        return [NSString stringWithFormat:@"%@=%@", CodingPercentEscapedQueryStringKeyFromStringWithEncoding([self.field description], stringEncoding), CodingPercentEscapedQueryStringValueFromStringWithEncoding([self.value description], stringEncoding)];
    }
}

@end

NSArray * CodingQueryStringPairsFromDictionary(NSDictionary *dictionary) {
    return CodingQueryStringPairsFromKeyAndValue(nil, dictionary);
}

NSArray * CodingQueryStringPairsFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            id nestedValue = [dictionary objectForKey:nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:CodingQueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            //------------------------------------------------------------
            //edited by easeeeeeeeee(modify)
            //            [mutableQueryStringComponents addObjectsFromArray:AFQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
            [mutableQueryStringComponents addObjectsFromArray:CodingQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@", key], nestedValue)];
            //------------------------------------------------------------
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            [mutableQueryStringComponents addObjectsFromArray:CodingQueryStringPairsFromKeyAndValue(key, obj)];
        }
    } else {
        [mutableQueryStringComponents addObject:[[CodingQueryStringPair alloc] initWithField:key value:value]];
    }
    
    return mutableQueryStringComponents;
}



static NSString * CodingQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding) {
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (CodingQueryStringPair *pair in CodingQueryStringPairsFromDictionary(parameters)) {
        [mutablePairs addObject:[pair URLEncodedStringValueWithEncoding:stringEncoding]];
    }
    
    return [mutablePairs componentsJoinedByString:@"&"];
}

static NSString *CodingGetSN(NSString *path, NSString *sk, NSDictionary *parameters){
    
    NSString *uri = [path stringByAppendingFormat:@"?%@",CodingQueryStringFromParametersWithEncoding(parameters, NSUTF8StringEncoding)];
    NSString *baseString = [[uri stringByAppendingString:sk] URLEncoding];
    
    return [baseString md5Str];
}

#pragma mark -


@implementation TweetSendCreateLocation

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ak = kBaiduAK;
        self.geotable_id = kBaiduGeotableId;
        self.coord_type = @"3";
        self.filter = @"";
        self.query = @"";
        self.radius = @(2000);
        self.page_size = @20;
        self.page_index = @0;
        User *user = [Login curLoginUser]? [Login curLoginUser]: [User userWithGlobalKey:@""];
        self.user_id = user.id;

    }
    return self;
}


- (NSDictionary *)toCreateParams
{
    NSMutableDictionary *dict = [@{@"ak":self.ak,@"geotable_id":self.geotable_id,@"coord_type":self.coord_type,@"radius":self.radius,@"address":self.address,@"latitude":self.latitude,@"longitude":self.longitude,@"title":self.title,@"user_id":self.user_id} mutableCopy];
    
    NSString *sn = CodingGetSN(kBaiduAPIGeosearchPathCreate,kBaiduSK,dict);
    
    [dict setValue:sn forKey:@"sn"];

    return dict;

}

- (NSDictionary *)toSearchParams
{
    self.filter = [NSString stringWithFormat:@"%@:[%@]",@"user_id",self.user_id];
    NSString *location = [NSString stringWithFormat:@"%@,%@",self.longitude,self.latitude];
    
    NSMutableDictionary *dict = [@{@"ak":self.ak,@"geotable_id":self.geotable_id,@"coord_type":self.coord_type,@"q":self.query,@"radius":self.radius,@"filter":self.filter,@"page_index":self.page_index,@"page_size":self.page_size,@"location":location} mutableCopy];
    
    
    NSString *sn = CodingGetSN(kBaiduAPIGeosearchPath,kBaiduSK,dict);
    
    DebugLog(@"%@",sn);
    
    [dict setValue:sn forKey:@"sn"];
    
    return dict;
}

@end

@implementation TweetSendLocationRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ak = kBaiduAK;
        self.query = @"$美食$休闲娱乐$宾馆$公司企业$旅游景点$道路$生活服务$医疗";
        self.page_num = @(0);
        self.page_size = @(20);
        self.scope = @"1";
        self.radius = @(2000);
        self.output = @"json";
    }
    return self;
}

- (NSDictionary *)toParams
{
    NSString *locationStr = [NSString stringWithFormat:@"%@,%@",self.lat,self.lng];

    NSMutableDictionary *dict = [@{@"ak":self.ak,@"output":self.output,@"query":self.query,@"page_size":self.page_size,@"page_num":self.page_num,@"scope":self.scope,@"location":locationStr,@"radius":self.radius} mutableCopy];
    
    NSString *sn = CodingGetSN(kBaiduAPIPlacePath,kBaiduSK,dict);
    
    DebugLog(@"%@",sn);
    
    [dict setValue:sn forKey:@"sn"];

    return dict;
}

@end

@implementation TweetSendLocationResponse
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.address = @"";
        self.cityName = @"";
        self.region = @"";
        self.title = @"";
        self.address = @"";
    }
    return self;
}

- (NSString *)address
{
    if (_address.length <= 0) {
        _address = [NSString stringWithFormat:@"%@,%@",self.cityName,self.region];
    }
    return _address;
}

- (NSString *)displayLocaiton
{
    NSString *locationStr = @"";
    NSRange range = [self.cityName rangeOfString:@"市"];
    
    if(range.location != NSNotFound){
        self.cityName = [self.cityName substringToIndex:range.location];
    }
    if (self.title.length > 0) {
        locationStr = [NSString stringWithFormat:@"%@ · %@",self.cityName,self.title];
    }else{
        locationStr = self.cityName;
    }
    if (locationStr.length > 32) {
        locationStr = [locationStr substringWithRange:NSMakeRange(0, 31)];
        locationStr = [locationStr stringByAppendingString:@"…"];
    }
    
    return locationStr;
}


@end

@implementation TweetSendLocationClient

+ (TweetSendLocationClient *)sharedJsonClient
{
    static TweetSendLocationClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TweetSendLocationClient alloc] initWithBaseURL:[NSURL URLWithString:kBaiduAPIUrl]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", nil];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    return self;
}

- (void)requestPlaceAPIWithParams:(TweetSendLocationRequest *)obj andBlock:(void (^)(id data, NSError *error))block
{
    [self GET:kBaiduAPIPlacePath parameters:[obj toParams] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DebugLog(@"\n===========response===========\n%@:\n%@", kBaiduAPIPlacePath, responseObject);
        id error = [self handleResponse:responseObject];
        if (error) {
            block(nil, error);
        }else{
            block(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DebugLog(@"\n===========response===========\n%@:\n%@", kBaiduAPIPlacePath, error);
        [NSObject showError:error];
        block(nil, error);
    }];
}

- (void)requestGeodataCreateWithParams:(TweetSendCreateLocation *)obj andBlock:(void (^)(id data, NSError *error))block
{
    [self POST:kBaiduAPIGeosearchPathCreate parameters:[obj toCreateParams] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DebugLog(@"\n===========response===========\n%@:\n%@", kBaiduAPIGeosearchPathCreate, responseObject);
        id error = [self handleResponse:responseObject];
        if (error) {
            block(nil, error);
        }else{
            block(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DebugLog(@"\n===========response===========\n%@:\n%@", kBaiduAPIGeosearchPathCreate, error);
        [NSObject showError:error];
        block(nil, error);
    }];
}

- (void)requestGeodataSearchCustomerWithParams:(TweetSendCreateLocation *)obj andBlock:(void (^)(id data, NSError *error))block
{
    [self GET:kBaiduAPIGeosearchPath parameters:[obj toSearchParams] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DebugLog(@"\n===========response===========\n%@:\n%@", kBaiduAPIGeosearchPath, responseObject);
        id error = [self handleResponse:responseObject];
        if (error) {
            block(nil, error);
        }else{
            block(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DebugLog(@"\n===========response===========\n%@:\n%@", kBaiduAPIGeosearchPath, error);
        [NSObject showError:error];
        block(nil, error);
    }];
}

@end


