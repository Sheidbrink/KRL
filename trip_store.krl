ruleset trip_store {
  meta {
    sharing on
    provides trips, long_trips, short_trips
  }

  global {
    trips = function() {
      ent:trips;
    }
    long_trips = function() {
      ent:long_trips;
    }
    short_trips = function() {
      ent:trips.difference(ent:long_trips);
    }
  }

  rule collect_trips {
    select when explicit trip_processed mileage "(.*)" setting(milg)
    fired {
      set ent:trips{[timestamp, "mileage"]} milg;
    }
  }

  rule collect_long_trips {
    select when explicit found_long_trip mileage "(.*)" setting(milg)
    fired {
      set ent:long_trips{[timestamp, "mileage"]} milg;
    }
  }

  rule clear_trips {
    select when car trip_reset
    fired {
      clear ent:long_trips;
      clear ent:trips;
    }
  }
}
