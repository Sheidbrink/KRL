ruleset vehicle {
  meta { 
    name "vehicle"
    description <<
      Ruleset to handle vehicle subscriptions
    >>
    author "Scott Heidbrink"
    use module b507199x5 alias wrangler_api
  }
  rule subscribeToParent {
    select when wrangler init_events
    pre {
      parent_results = wrangler_api:parent();
      parent = parent_results{'parent'};
      parent_eci = parent[0];
      attributes = {}.put(["name"], event:attr("sname"))
                .put(["name_space"], "Vehicle_Subscript")
                .put(["my_role"], "Child")
                .put(["your_role"], "Parent")
                .put(["target_eci"], parent_eci.klog("target Eci: "))
                .put(["channel_type"], "Pico_Tutorial")
                .put(["attrs"], "success");
    }
    {
      event:send({"cid":meta:eci()}, "wrangler", "subscription") with attrs = attributes.klog("attributes: ");
    }
  }
}
