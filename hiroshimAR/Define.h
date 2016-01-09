// リリースビルドには NSLog を含めない為のマクロ
// Log の代わりに、LOG(@"hoge"); として使う。
#define DEBUG 1 //debug mode = 1 else 0


#ifdef DEBUG
#define LOG(...) NSLog(__VA_ARGS__) 
#else 
#define LOG(...) 
#endif


// デフォルト位置
#define GROUND_ZERO_LATITUDE 34.391544
#define GROUND_ZERO_LONGITUDE 132.453115

#define GROUND_ZERO_SPAN 0.030
#define CURRENT_LOCATION_SPAN 0.005

#define SENDAI_AIRPORT_LATITUDE 34.391544
#define SENDAI_AIRPORT_LONGITUDE 132.453115

// AR
#define Y_DISP_HEIGHT			426		// カメラビューの高さ
#define Y_DISP_UPPER			400		// コールアウトの上限Y位置
#define	ACCY_AT_HANDLING		0.40	// 手持位置でのY加速度
#define	ACCY_AT_HOLIZONTAL		0.05	// 水平位置でのY加速度
#define VIEWPORT_WIDTH_RADIANS	.7392	// ビューポートの幅（ラジアン）
#define VIEWPORT_HEIGHT_RADIANS .5// ビューポートの高さ（ラジアン）
#define NEAR_BY_DISTANCE        300    // 現在位置とAR対象物の距離で表示する距離の範囲(m)

// 加速度
#define kFilteringFactor		0.1		// 加速度検知の感度係数


//#define kOAuthConsumerKey        @"PsDOntvouPekRMdmwsWZQQ"         //REPLACE With Twitter App OAuth Key  
//#define kOAuthConsumerSecret    @"IOGxDp2nnsNcEDaf0OnZQdUh2jKUdydcnu6n7aoCA"     //REPLACE With Twitter App OAuth Secret 


//#define kOAuthConsumerKey        @"q8ziHp4SymC35XGJwggoyQ"         //REPLACE With Twitter App OAuth Key  
//#define kOAuthConsumerSecret    @"SUvTN67TGqky26pbKAs0YuEYE22q6SY9MDctP27P44"     //REPLACE With Twitter App OAuth Secret 
//#define kTwitPicAPIKey @"6116dc88b3640a531d930f8bfec4cb24"


#define kOAuthConsumerKey        @"8kzvVkVgx7g4lE890Zw"         //REPLACE With Twitter App OAuth Key  
#define kOAuthConsumerSecret    @"6MXLUhnJV6k948ZPu3IAWXWh5URPLa66mO3wuNYM44"     //REPLACE With Twitter App OAuth Secret 
#define kTwitPicAPIKey @"6116dc88b3640a531d930f8bfec4cb24"


