ruleset track_trips {
  rule process_trip {
    select when car new_trip mileage "(.*)" setting(milg)
    send_directive("trip") with
      trip_length = milg;
  }
}
