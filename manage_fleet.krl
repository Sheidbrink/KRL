ruleset manage_fleet {
  meta { 
    name "manage_fleet"
    description <<
      The manage fleet pico
    >>
    author "Scott Heidbrink"
    use module b507199x5 alias wranglerOS
    sharing on
    provides vehicles, alltrips, cloud, report
  }

  global {
        cloud_url = "https://#{meta:host()}/sky/cloud/";
        cloud = function(eci, mod, func, params) {
            response = http:get("#{cloud_url}#{mod}/#{func}", (params || {}).put(["_eci"], eci));
            status = response{"status_code"};
            response_content = response{"content"}.decode();
            response_content
        };

    vehicles = function() {
      results = wranglerOS:subscriptions();
      subscriptions = results{"subscriptions"};
      subscriptions{"subscribed"}.filter(
				function(x) {
						vals=x.values();
						myvals=vals.head();
						myvals{"name_space"} eq "Vehicle_Subscriptions";
						}
					);
    }
    alltrips = function() {
      //stupid = vehicles().klog("VEHICLES: ");
      trips = vehicles().map(function(x) {
					vals=x.values().klog("Subscriptions: ");
					myvals=vals.head().klog("Heads: ");
					eci=myvals{"event_eci"}.klog("ecis: ");
					//toReturn=wranglerOS:skyQuery(eci,pds,profile,"trips")
					toReturn=cloud(eci,"b507766x6","trips",{})
						.klog("trips: ");
					toReturn;
				}
			);
     trips;
    }
    report = function () {
       ent:report;
    }
  }

  rule request_report {
    select when fleet generate_report
	foreach vehicles() setting (vehicle)
	  pre{
		vals=vehicle.values().klog("VALUES: ");
		myvals = vals.head();
		eci = myvals{"event_eci"}.klog("vehicle eci: ");
		name = vehicle.keys().head().klog("vehicle name: ");
	}
	{
		event:send({"cid":eci}, "car", "send_report") with attrs = {}.put(["name"], name).klog("sending :" );
	}
    }
  

  rule collect_report {
    select when fleet collect_report
    pre {
      name = event:attr("name").klog("vehicle name: ");
      trips = event:attr("trips").klog("the trips: ");
      index = ent:indx;
      next_index = (index > 5) => 0 | (index + 1);
    }
    fired {
      clear ent:report;
      set ent:report{[index, name]} trips;
      set ent:indx next_index;
      log(ent:report);
    }
  }

  rule delete_vehicle {
    select when car unneeded_vehicle
    pre {
	eci = event:attr("deleteeci");
	name = event:attr("channel_name");
    }
    {
      event:send({"cid":meta:eci()}, "wrangler", "child_deletion") 
	with attrs = {}.put(["deletionTarget"], eci).klog("attributes for delete: ");
      event:send({"cid":meta:eci()}, "wrangler", "subscription_cancellation") 
	with attrs = {}.put(["channel_name"], name).klog("attributes for unsubscription: ");
    }
  }

  rule create_vehicle {
    select when car new_vehicle
    //create a pico
    pre {
      attributes = {}.put(["Prototype_rids"],"b507766x6;b507766x5")
                     .put(["name"],event:attr("name"))
                     .put(["sname"],event:attr("sname"));
    }
    {
      noop();
      event:send({"cid":meta:eci().klog("meta eci:" )}, "wrangler", "child_creation")
         with attrs = attributes.klog("attributes: ");
    }
  }

  rule autoAccept {
    select when wrangler inbound_pending_subscription_added
    pre {
      attributes = event:attrs().klog("subscription :");
    }
    {
      event:send({"cid":meta:eci()}, "wrangler", "pending_subscription_approval") with attrs = attributes.klog("attributes: ");
      log("auto accepted subscription.");
    }
  }
}
