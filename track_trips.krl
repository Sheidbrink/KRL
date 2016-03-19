ruleset track_trips {
  rule process_trip {
    select when echo message mileage "(.*)" setting(milg)
    send_directive("trip") with
      trip_length = milg;
  }
}
