ruleset manage_fleet {
  meta { 
    name "manage_fleet"
    description <<
      The manage fleet pico
    >>
    author "Scott Heidbrink"
    use module b507199x5 alias wranglerOS
    sharing on
    provides vehicles
  }

  global {
    vehicles = function() {
      results = wranglerOS:subscriptions();
      subscriptions = results{"subscriptions"}.filter(function(x) {x{["subscribed", "name_space"]} == reg"Vehicle_Subscriptions:*" } );
      subscriptions;
    }
    //alltrips = function() {
    //  foreach subscription setting (x)
        //call trips
    //}
  }

  rule delete_vehicle {
    select when car unneeded_vehicle
    pre {
      attributes = {}.put(["channel_name"],event:attr("channel_name"))
                     .put(["deletionTarget"], event:attr("deleteeci"));
    }
    {
      event:send({"cid":meta:eci()}, "wrangler", "subscription_cancellation") with attrs = attributes("attributes: ");
      event:send({"cid":meta:eci()}, "wrangler", "child_deletion") with attrs = attributes("attributes: ");
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
