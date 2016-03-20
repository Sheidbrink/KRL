ruleset trip_store {
  meta {
    author "Scott Heidbrink"
    sharing on
    provides trips, long_trips, short_trips
  }

  global {
    trips = function() {
      ent:trips.klog("test");
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
      milg.klog("Adding mlog: ");
      set ent:trips{time:now()} milg;
      ent:trips.klog("Trips so far: ");
    }
  }

  rule collect_long_trips {
    select when explicit found_long_trip mileage "(.*)" setting(milg)
    fired {
      set ent:long_trips{time:now()} milg;
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
