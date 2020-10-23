# API

## パトライト

a ... g  : on
h : off

```

curl localhost:8081?b        # on with 'b'
curl localhost:8081?h        # off

```

## iRemocon

*から始まるパラメータと、iRemoconのIPアドレスを、カンマでつないだもの

[ここ](http://i-remocon.com/hp/documents/IRM01L_command_ref.pdf)のリファレンスを参照のこと(\r\nは含まない）


```
curl 'localhost:8081?*au,192.168.2.50'    # 接続テスト
curl 'localhost:8081?*ic;50,192.168.2.50'    # 50番に学習開始
curl 'localhost:8081?*is;50,192.168.2.50'    # 50番に学習されているものを送信

```

## センサー

引数はcallback=..のみ（JSONP access)

```
curl localhost:8081?callback=jsonp_12345
```

返答例：
```json
{
	"time_measured": "2020/10/23 15:50:33",
	"temperature": "27.48",
	"relative_humidity": "64.72",
	"ambient_light": "460",
	"barometric_pressure": "990.616",
	"sound_noise": "57.61",
	"eTVOC": "17",
	"eCO2": "517",
	"discomfort_index": "76.91",
	"heat_stroke": "25.37",
	"vibration_information": "0",
	"si_value": "0.0",
	"pga": "0.0",
	"seismic_intensity": "0.0",
	"temperature_flag": "0",
	"relative_humidity_flag": "0",
	"ambient_light_flag": "0",
	"barometric_pressure_flag": "0",
	"sound_noise_flag": "0",
	"etvoc_flag": "0",
	"eco2_flag": "0",
	"discomfort_index_flag": "0",
	"heat_stroke_flag": "0",
	"si_value_flag": "0",
	"pga_flag": "0",
	"seismic_intensity_flag": "0"
}
```
