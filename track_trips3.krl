ruleset track_trips {
  meta {
    name "track_trips_v3"
    use module  b507199x5 alias wrangler_api
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
      ent:trips.filter(function(k,v){ent:trips{k} != ent:long_trips{k}});
    }
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
    pre {
        attrsLog = event:attrs().klog("My attributes are: ");
    }
    fired {
      raise explicit event 'found_long_trip' attributes event:attrs() if milg > long_trip;
      log("Proof (4) works: " + attrsLog);
    }
  }

  rule collect_trips {
    select when explicit trip_processed mileage "(.*)" setting(milg)
    fired {
      log("Adding mlog: " + milg);
      set ent:trips{time:now()} milg;
      log("Trips so far: " + ent:trips);
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

  rule send_report {
    select when car send_report
    pre {
      parent_results = wrangler_api:parent();
      parent = parent_results{'parent'};
      parent_eci = parent[0];
    }
    {
      event:send({"eci": parent_eci}, "fleet", "collect_report") with attrs = {}.put(["trips"], trips());
    }
  }



}
