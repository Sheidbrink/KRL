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
    long_trip = 10
  }
  rule create_vehicle {
    select when car new_vehicle
    //create a pico
    pre {
      attributes= {}.put(["Prototype_rids"],"b507766x2").put(["name"],event:attr("name").klog("Create vehicle: "));
    }
    {
      event:send({"cid":meta:eci()}, "wrangler", "child_creation")
        with attrs = attributes.klog("attributes: ");
    }
    //subscription between this pico and the vehicle
    //install the track _trips rulset b507766x2
  }
}
