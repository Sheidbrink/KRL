ruleset vehicle {
  meta { 
    name "vehicle"
    description <<
      Ruleset to handle vehicle subscriptions
    >>
    author "Scott Heidbrink"
    use module b507199x5 alias wranglerOS
  }
  rule subscribeToParent {
    select when wrangler init_events
    pre {
      parent_results = wrangler_api:parent();
      parent = parent_results{'parent'};
      parent_eci = parent[0];
      attrs = {}.put(["name"], "Family")
                .put(["name_space"], "Tutorial_Subscriptions")
                .put(["my_role"], "Child")
                .put(["your_role"], "Parent")
                .put(["target_eci"], parent_eci.klog("target Eci: "))
                .put(["channel_type"], "Pico_Tutorial")
                .put(["attrs"], "success");
    }
    {
      noop();
    }
    always {
      raise wrangler event "subscription"
      attributes attrs;
    }
  }
}
