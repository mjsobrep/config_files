# reverse speakers left-right
index=$(pacmd list-sinks|grep -B 1 analog-stereo | grep index | tr -d "\n" | tail -c 1)
echo "remapping for index: $index"
pacmd set-sink-volume "$index" 65536
pacmd load-module module-remap-sink sink_name=reverse-stereo master="$index" channels=2 master_channel_map=front-right,front-left channel_map=front-left,front-right
pacmd set-default-sink reverse-stereo
