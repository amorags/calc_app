#!/usr/bin/env bash

# See https://docs.flutter.dev/cookbook/testing/integration/introduction#5b-web

# If "debug" arg is given we run in brower, otherwise run headless
if [ "$1" = "debug" ]; then
  DRIVER=chrome
else
  DRIVER=web-server
fi
echo "Driver $DRIVER"

# Download chromedriver if not found
if ! (type chromedriver &> /dev/null) && [ ! -f "chromedriver" ]; then
  dart run test_driver/download_chromedriver.dart 
fi

# Start chromedriver
if (type chromedriver &> /dev/null); then
  chromedriver --port=4444 &
else
  ./chromedriver --port=4444 &
fi
sleep 2s

# Run tests
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  -d $DRIVER

kill `ps | grep chromedriver | awk '{print($1)}'`
