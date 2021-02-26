DEVICE_NUM=/dev/video0
v4l2-ctl -d $DEVICE_NUM --set-ctrl=white_balance_temperature_auto=0
v4l2-ctl -d $DEVICE_NUM --set-ctrl=white_balance_temperature=4200

#v4l2-ctl -d /dev/video0 --set-ctrl=exposure_auto=1
#v4l2-ctl -d /dev/video0 --set-ctrl=exposure_auto_priority=0
#v4l2-ctl -d /dev/video0 --set-ctrl=gain=10
##For exposure, valid settings are: 19, 38,77, 155,312, 624, 1250, 2047
v4l2-ctl -d $DEVICE_NUM --set-ctrl=exposure_absolute=77

#v4l2-ctl -d /dev/video0 --set-ctrl=zoom_absolute=100

v4l2-ctl -d $DEVICE_NUM --all
