ruleset manage_fleet {
  meta { 
    name "manage_fleet"
    description <<
      The manage fleet pico
    >>
    author "Scott Heidbrink"
    use module b507199x5 alias wranglerOS
  }

  global {
    vehicles = function() {
      results = wranglerOS:subscriptions();
      subscriptions = results{"subscriptions"};
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
      // b507766x2 is the trips ruleset
      attributes = {}.put(["Prototype_rids"],"b507766x6").put(["name"],event:attr("name").klog("Create vehicle: "));
    }
    {
      noop();
      event:send({"cid":meta:eci()}, "wrangler", "child_creation")
         with attrs = attributes.klog("attributes: ");
    }
  }

  rule autoAccept {
    select when wrangle inbound_pending_subscription_added
    pre {
      attributes = event:attrs().klog("subscription :");
    }
    {
      event:send({"cid":meta:eci()}, "wrangler", "pending_subscription_approval") with attrs = attributes.klog("attributes: ");
      log("auto accepted subscription.");
    }
  }
}
