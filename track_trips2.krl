ruleset track_trips {
  global {
    long_trip = 10
  }
  rule process_trip {
    select when car new_trip mileage "(.*)" setting(milg)
      send_directive("trip") with
        trip_length = milg;
      fired {
        raise explicit event 'trip_processed' attributes event:attrs();
      }
  }
  rule find_long_trips {
    select when explicit trip_processed mileage "(.*)" setting(milg)
    fired {
      raise explicit event 'found_long_trip' if milg > long_trip;
    }
  }
}
