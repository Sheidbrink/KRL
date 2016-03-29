ruleset manage_fleet {
  meta { 
    name "manage_fleet"
    description <<
      The manage fleet pico
    >>
    author "Scott Heidbrink"
    use module b507199x5 alias wranglerOS
  }
  rule create_vehicle {
    select when car new_vehicle
    //create a pico
    pre {
      // b507766x2 is the trips ruleset
      attributes= {}.put(["Prototype_rids"],"b507766x2").put(["name"],event:attr("name").klog("Create vehicle: "));
    }
    {
      noop();
    }
    always {
      raise wrangler event "child_creation"
      attributes attr.klog("attributes: ");
      log("create child for " + child);
      //subscription between this pico and the vehicle
      
      //install the track _trips rulset b507766x2
    }
  }

  rule autoAccept {
    select when wrangle inbound_pending_subscription_added
    pre {
      attributes = event:attrs().klog("subscription :");
    }
    {
      noop();
    }
    always {
      raise wrangler event 'pending_subscription_approvel'
        attributes attributes;
        log("auto accepted subscription.");
    }
  }
}
