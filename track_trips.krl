ruleset track_trips {
  rule process_trip is active {
    select when echo message mileage "(.*)" setting(milg)
    send_directive("trip") with
      trip_length = milg;
  }
}
