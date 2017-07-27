// リリースビルドには NSLog を含めない為のマクロ
// Log の代わりに、LOG(@"hoge"); として使う。
#define DEBUG 1 //debug mode = 1 else 0


#ifdef DEBUG
#define LOG(...) NSLog(__VA_ARGS__) 
#else 
#define LOG(...) 
#endif

// Config

// デフォルト位置のカメラパラメータ
//#define GROUND_ZERO_LATITUDE        35.678086
//#define GROUND_ZERO_LONGITUDE       139.714935
#define GROUND_ZERO_LATITUDE        34.39478216914307
#define GROUND_ZERO_LONGITUDE       132.4547065677773
#define GROUND_ZERO_CAMERA_PITCH    65          // カメラ傾斜
#define GROUND_ZERO_CAMERA_ALTITUDE 100000       // カメラ高度

// 現在地のカメラパラメータ
#define CURRENT_LOCATION_CAMERA_PITCH 70
#define CURRENT_LOCATION_CAMERA_ALTITUDE 500

// AR
#define Y_DISP_HEIGHT               426         // カメラビューの高さ
#define Y_DISP_UPPER                400         // コールアウトの上限Y位置
#define	ACCY_AT_HANDLING            0.40        // 手持位置でのY加速度
#define	ACCY_AT_HOLIZONTAL          0.05        // 水平位置でのY加速度
#define VIEWPORT_WIDTH_RADIANS      .7392       // ビューポートの幅（ラジアン）
#define VIEWPORT_HEIGHT_RADIANS     .5          // ビューポートの高さ（ラジアン）
#define kARViewToolbarHight         55.0f       // ツールバー高さ
#define kARViewHeight               400.0f      // ARビューの高さ
#define NEAR_BY_DISTANCE            20000000       // 現在位置とAR対象物の距離で表示する距離の範囲(m)
#define AR_MARKER_MAXIMUM_NUMBER    10          // ARマーカの最大数
#define InfoTagEstimateHeight       20.0f       // デフォルトのマーカ間隔
#define MARKER_INTERVAL             1.6         // マーカ間隔の調整用パラメータ（乗数）
#define AR_REFRESH_TIMER            0.1f        // マーカ描画リフレッシュ間隔

// 加速度
#define kFilteringFactor            0.05		// 加速度検知の感度係数


