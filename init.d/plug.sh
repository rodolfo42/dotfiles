plug () {
  local keyboard=$KEYBOARD_ADDRESS
  local trackpad=$TRACKPAD_ADDRESS
  local devices=("$keyboard" "$trackpad")

  for address in "${devices[@]}"; do
    if [[ "$address" == *"cb" ]]; then
      local device_name="⌨️ Keyboard"
    else
      local device_name="⬜️ Trackpad"
    fi

    echo "--------------------------------"
    echo "Processing $device_name ($address)"

    echo "🔌 Unpairing $device_name ($address)..."
    blueutil --unpair "$address" 2>/dev/null || true

    echo "🔍 Searching for $device_name ($address)..."
    if blueutil --inquiry 5 | grep -q "$address"; then
      echo "🟢 Found $device_name ($address), attempting to connect..."
      if ! blueutil --connect "$address"; then
        echo "🔴 Error connecting to $device_name ($address)"
      fi
    else
      echo "⏳ $device_name ($address) not found in first (5s) inquiry, trying extended (20s) search..."
      sleep 1
      if blueutil --inquiry 20 | grep -q "$address"; then
        echo "✅ Found $device_name ($address) in extended search, attempting to connect..."
        if ! blueutil --connect "$address"; then
          echo "🔴 Error connecting to $device_name ($address)"
        fi
      else
        echo "🔴 $device_name ($address) not found in either (5s) or (20s) inquiry"
      fi
    fi
  done
}

unplug () {
  local keyboard=$KEYBOARD_ADDRESS
  local trackpad=$TRACKPAD_ADDRESS
  local devices=("$keyboard" "$trackpad")

  for address in "${devices[@]}"; do
    if [[ "$address" == *"cb" ]]; then
      local device_name="⌨️ Keyboard"
    else
      local device_name="⬜️ Trackpad"
    fi

    echo "--------------------------------"
    echo "⚙️ Processing $device_name ($address)"

    echo "🔌 Unpairing $device_name ($address)..."
    if blueutil --unpair "$address" 2>/dev/null; then
      echo "🟢 Successfully unpaired $device_name ($address)"
    else
      echo "🔵 Warning: unpairing $device_name ($address) or device was not paired"
    fi
  done
}
