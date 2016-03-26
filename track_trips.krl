ruleset track_trips {
  meta {
    name "track_trips_v1"
  }
  rule process_trip {
    select when echo message mileage "(.*)" setting(milg)
    send_directive("trip") with
      trip_length = milg;
  }
}
